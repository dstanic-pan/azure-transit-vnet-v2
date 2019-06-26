#!/usr/bin/env python3
"""
# Copyright (c) 2018, Palo Alto Networks
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# Author: Justin Harris jharris@paloaltonetworks.com

Usage

python deploy.py -u <fwusername> -p<fwpassword> -r<resource group> -j<region>

"""

import argparse
import json
import logging
import os
import subprocess
import sys
import time
import uuid
import xml.etree.ElementTree as ET
import xmltodict
import requests
import urllib3

from azure.common import AzureException
from azure.storage.file import FileService


from pandevice import firewall
from python_terraform import Terraform
from collections import OrderedDict


urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

_archive_dir = './WebInDeploy/bootstrap'
_content_update_dir = './WebInDeploy/content_updates/'

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()
handler = logging.StreamHandler()
formatter = logging.Formatter('%(levelname)-8s %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)


# global var to keep status output
status_output = dict()


def send_request(call):

    """
    Handles sending requests to API
    :param call: url
    :return: Retruns result of call. Will return response for codes between 200 and 400.
             If 200 response code is required check value in response
    """
    headers = {'Accept-Encoding' : 'None',
               'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) '
                              'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36'}

    try:
        r = requests.get(call, headers = headers, verify=False, timeout=5)
        r.raise_for_status()
    except requests.exceptions.HTTPError as errh:
        '''
        Firewall may return 5xx error when rebooting.  Need to handle a 5xx response 
        '''
        logger.debug("DeployRequestException Http Error:")
        raise DeployRequestException("Http Error:")
    except requests.exceptions.ConnectionError as errc:
        logger.debug("DeployRequestException Connection Error:")
        raise DeployRequestException("Connection Error")
    except requests.exceptions.Timeout as errt:
        logger.debug("DeployRequestException Timeout Error:")
        raise DeployRequestException("Timeout Error")
    except requests.exceptions.RequestException as err:
        logger.debug("DeployRequestException RequestException Error:")
        raise DeployRequestException("Request Error")
    else:
        return r


class DeployRequestException(Exception):
    pass

def walkdict(dict, match):
    """
    Finds a key in a dict or nested dict and returns the value associated with it
    :param d: dict or nested dict
    :param key: key value
    :return: value associated with key
    """
    for key, v in dict.items():
        if key == match:
            jobid = v
            return jobid
        elif isinstance(v, OrderedDict):
            found = walkdict(v, match)
            if found is not None:
                return found


def update_status(key, value):
    """
    For tracking purposes.  Write responses to file.
    :param key:
    :param value:
    :return:
    """
    global status_output

    if type(status_output) is not dict:
        logger.info('Creating new status_output object')
        status_output = dict()

    if key is not None and value is not None:
        status_output[key] = value

    # write status to file to future tracking
    write_status_file(status_output)


def write_status_file(message_dict):
    """
    Writes the deployment state to a dict and outputs to file for status tracking
    """
    try:
        message_json = json.dumps(message_dict)
        with open('deployment_status.json', 'w+') as dpj:
            dpj.write(message_json)

    except ValueError as ve:
        logger.error('Could not write status file!')
        print('Could not write status file!')
        sys.exit(1)


def create_azure_fileshare(share_prefix, account_name, account_key):
    """
    Generate a unique share name to avoid overlaps in shared infra
    :param share_prefix:
    :param account_name:
    :param account_key:
    :return:
    """

    # FIXME - Need to remove hardcoded directoty link below

    d_dir = './WebInDeploy/bootstrap'
    share_name = "{0}-{1}".format(share_prefix.lower(), str(uuid.uuid4()))
    print('using share_name of: {}'.format(share_name))

    # archive_file_path = _create_archive_directory(files, share_prefix)

    try:
        # ignore SSL warnings - bad form, but SSL Decrypt causes issues with this
        s = requests.Session()
        s.verify = False

        file_service = FileService(account_name=account_name, account_key=account_key, request_session=s)

        # print(file_service)
        if not file_service.exists(share_name):
            file_service.create_share(share_name)

        for d in ['config', 'content', 'software', 'license']:
            print('creating directory of type: {}'.format(d))
            if not file_service.exists(share_name, directory_name=d):
                file_service.create_directory(share_name, d)

            # FIXME - We only handle bootstrap files.  May need to handle other dirs

            if d == 'config':
                for filename in os.listdir(d_dir):
                    print('creating file: {0}'.format(filename))
                    file_service.create_file_from_path(share_name, d, filename, os.path.join(d_dir, filename))

    except AttributeError as ae:
        # this can be returned on bad auth information
        print(ae)
        return "Authentication or other error creating bootstrap file_share in Azure"

    except AzureException as ahe:
        print(ahe)
        return str(ahe)
    except ValueError as ve:
        print(ve)
        return str(ve)

    print('all done')
    return share_name


def getServerStatus(IP):
    """
    Gets the server status by sending an HTTP request and checking for a 200 response code

    """
    global gcontext

    call = ("http://" + IP + "/")
    logger.info('URL request is {}'.format(call))
    # Send command to fw and see if it times out or we get a response
    count = 0
    max_count = 12
    while True:
        if count < max_count:
            time.sleep(10)
            try:
                count = count + 1
                r = send_request(call)
            except DeployRequestException as e:
                logger.debug("Got Invalid response".format(e))
            else:
                logger.info('Jenkins Server responded with HTTP 200 code')
                return 'server_up'
        else:
            break
    return 'server_down'


def apply_tf(working_dir, vars, description):

    """
    Handles terraform operations and returns variables in outputs.tf as a dict.
    :param working_dir: Directory that contains the tf files
    :param vars: Additional variables passed in to override defaults equivalent to -var
    :param description: Description of the deployment for logging purposes
    :return:    return_code - 0 for success or other for failure
                outputs - Dictionary of the terraform outputs defined in the outputs.tf file

    """
    # Set run_plan to TRUE is you wish to run terraform plan before apply
    run_plan = False
    kwargs = {"auto-approve": True}

    # Class Terraform uses subprocess and setting capture_output to True will capture output
    capture_output = kwargs.pop('capture_output', False)

    if capture_output is True:
        stderr = subprocess.PIPE
        stdout = subprocess.PIPE
    else:
        # if capture output is False, then everything will essentially go to stdout and stderrf
        stderr = sys.stderr
        stdout = sys.stdout

    start_time = time.asctime()
    print('Starting Deployment at {}\n'.format(start_time))

    # Create Bootstrap

    tf = Terraform(working_dir=working_dir)

    tf.cmd('init')
    if run_plan:

        # print('Calling tf.plan')
        tf.plan(capture_output=False)

    return_code, stdout, stderr = tf.apply(vars = vars, capture_output = capture_output,
                                            skip_plan = True, **kwargs)
    outputs = tf.output()

    logger.debug('Got Return code {} for deployment of  {}'.format(return_code, description))

    return (return_code, outputs)


def main(username, password, rg_name, azure_region):

    """
    Main function
    :param username:
    :param password:
    :param rg_name: Resource group name prefix
    :param azure_region: Region
    :return:
    """
    username = username
    password = password

    WebInBootstrap_vars = {
        'RG_Name': rg_name,
        'Azure_Region': azure_region
    }

    WebInDeploy_vars = {
        'Admin_Username': username,
        'Admin_Password': password,
        'Azure_Region': azure_region
    }

    WebInFWConf_vars = {
        'Admin_Username': username,
        'Admin_Password': password
    }

    # Set run_plan to TRUE is you wish to run terraform plan before apply
    run_plan = False
    kwargs = {"auto-approve": True}

    #
    return_code, outputs = apply_tf('./WebInBootstrap',WebInBootstrap_vars, 'WebInBootstrap')

    if return_code == 0:
        share_prefix = 'azure-demo'
        resource_group = outputs['Resource_Group']['value']
        bootstrap_bucket = outputs['Bootstrap_Bucket']['value']
        storage_account_access_key = outputs['Storage_Account_Access_Key']['value']
        update_status('web_in_bootstrap_status', 'success')
    else:
        logger.info("WebInBootstrap failed")
        update_status('web_in_bootstap_status', 'error')
        print(json.dumps(status_output))
        exit(1)


    share_name = create_azure_fileshare(share_prefix, bootstrap_bucket, storage_account_access_key)

    WebInDeploy_vars.update({'Storage_Account_Access_Key': storage_account_access_key})
    WebInDeploy_vars.update({'Bootstrap_Storage_Account': bootstrap_bucket})
    WebInDeploy_vars.update({'RG_Name': resource_group})
    WebInDeploy_vars.update({'Attack_RG_Name': resource_group})
    WebInDeploy_vars.update({'Storage_Account_Fileshare': share_name})

    #
    # Build Infrastructure
    #
    #


    return_code, web_in_deploy_output = apply_tf('./WebInDeploy', WebInDeploy_vars, 'WebInDeploy')

    logger.debug('Got Return code for deploy WebInDeploy {}'.format(return_code))


    update_status('web_in_deploy_output', web_in_deploy_output)
    if return_code == 0:
        update_status('web_in_deploy_status', 'success')
        albDns = web_in_deploy_output['ALB-DNS']['value']
        fwMgt = web_in_deploy_output['MGT-IP-FW-1']['value']
        nlbDns = web_in_deploy_output['NLB-DNS']['value']
        fwMgtIP = web_in_deploy_output['MGT-IP-FW-1']['value']

        logger.info("Got these values from output of WebInDeploy \n\n")
        logger.info("AppGateway address is {}".format(albDns))
        logger.info("Internal loadbalancer address is {}".format(nlbDns))
        logger.info("Firewall Mgt address is {}".format(fwMgt))

    else:
        logger.info("WebInDeploy failed")
        update_status('web_in_deploy_status', 'error')
        print(json.dumps(status_output))
        exit(1)

    #
    # Check firewall is up and running
    #
    #

    api_key = getApiKey(fwMgtIP, username, password)

    while True:
        err = getFirewallStatus(fwMgtIP, api_key)
        if err == 'cmd_error':
            logger.info("Command error from fw ")

        elif err == 'no':
            logger.info("FW is not up...yet")
            # print("FW is not up...yet")
            time.sleep(60)
            continue

        elif err == 'almost':
            logger.info("MGT up waiting for dataplane")
            time.sleep(20)
            continue

        elif err == 'yes':
            logger.info("FW is up")
            break

    logger.debug('Giving the FW another 10 seconds to fully come up to avoid race conditions')
    time.sleep(10)
    fw = firewall.Firewall(hostname=fwMgtIP, api_username=username, api_password=password)


    logger.info("Updating firewall with latest content pack")
    update_fw(fwMgtIP, api_key)

    #
    # Configure Firewall
    #
    WebInFWConf_vars.update({'FW_Mgmt_IP': fwMgtIP})

    logger.info("Applying addtional config to firewall")

    return_code, web_in_fw_conf_out = apply_tf('./WebInFWConf', WebInFWConf_vars, 'WebInFWConf')

    if return_code == 0:
        update_status('web_in_fw_conf', 'success')
        logger.info("WebInFWConf failed")

    else:
        logger.info("WebInFWConf failed")
        update_status('web_in_deploy_status', 'error')
        print(json.dumps(status_output))
        exit(1)

    logger.info("Commit changes to firewall")

    fw.commit()
    logger.info("waiting for commit")
    time.sleep(60)
    logger.info("waiting for commit")

    #
    # Check Jenkins
    #

    logger.info('Checking if Jenkins Server is ready')

    res = getServerStatus(albDns)

    if res == 'server_up':
        logger.info('Jenkins Server is ready')
        logger.info('\n\n   ### Deployment Complete ###')
        logger.info('\n\n   Connect to Jenkins Server at http://{}'.format(albDns))
    else:
        logger.info('Jenkins Server is down')
        logger.info('\n\n   ### Deployment Complete ###')

    # dump out status to stdout
    print(json.dumps(status_output))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Get Terraform Params')
    parser.add_argument('-u', '--username', help='Firewall Username', required=True)
    parser.add_argument('-p', '--password', help='Firewall Password', required=True)
    parser.add_argument('-r', '--resource_group', help='Resource Group', required=True)
    parser.add_argument('-j', '--azure_region', help='Azure Region', required=True)

    args = parser.parse_args()
    username = args.username
    password = args.password
    resource_group = args.resource_group
    azure_region = args.azure_region

    main(username, password, resource_group, azure_region)
