from pprint import pprint
import urllib3

import isi_sdk_9_0_0
from isi_sdk_9_0_0.rest import ApiException

urllib3.disable_warnings()

# configure username and password
configuration = isi_sdk_9_0_0.Configuration()
configuration.username = "root"
configuration.password = "a"
configuration.verify_ssl = False

# configure host
configuration.host = "https://10.246.156.13:8080"
api_client = isi_sdk_9_0_0.ApiClient(configuration)
protocols_api = isi_sdk_9_0_0.ProtocolsApi(api_client)

# get all exports
sort = "description"
limit = 50
dir = "ASC"
try:
    api_response = protocols_api.list_nfs_exports(sort=sort, limit=limit, dir=dir)
    pprint(api_response)
except ApiException as e:
    print ('Exceptions when calling ProtocolsApi->list_nfs_exports:') %s % e
