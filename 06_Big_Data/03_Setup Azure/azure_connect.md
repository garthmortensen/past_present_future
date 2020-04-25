# Big Data

Get up and running with Azure  

2020.02.29  

## Connect to Azure

Create an Azure account.

Create a blob container.

Upload a file into the container.

### Shares Access Signature

Setup a Shared Access Signature, which gives far greater control of access level. If using API key, then it's just default access. With SAS, you can give different permissions like read/write/delete/add/create, etc. You can also set an expiration date and time, so that the access expires. You can allow certain IP addresses, etc.

### Create VM

Pre-startup notes:

1. Setup auto shut down to preserve your credits. 

2. Stopping the VM will deallocate it, not charge you, and when you start it back up, everything will be the same.

I'll be launching an Ubuntu Data Science Virtual Machine. But to connect to it, I could do one of three things:

- SSH for terminal
- X2Go for graphical. X2Go performed better than X11 during Azure's testing.
- JupyterHub and JupyterLab for Jupyter notebooks

Download [X2Go](https://wiki.x2go.org/doku.php/doc:installation:x2goclient), and install. 

Launch the VM and take note of:

* Username
* Password
* Public IP 

In X2Go, provide the following input.

- Host: VM IP address
- Login: Username on the VM.
- SSH Port: 22
- Session Type: XFCE. Currently, the Linux VM supports only the XFCE desktop.

Click Launch.

Super cool! You have access to all sorts of data science tools.

### Launch JupyterHub

There exists in the VM access to a JupyterHub (i think) server. To access it, open the browser and navigate to:

> https://yourIPAddress:8000

### Update Python SDK?

Currently, this Data Science VM has Python SDK blob storage 2.1.

Confirm this by running in terminal:

```shell
pip list | grep azure-storage-blob
2.0.1
```

We are running 2.1, so we need to use [this](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-python-legacy) resource. <font color="red">What is this 2.1 vs 2.0.1? SDK for what?</font>

We need to run [BlockBlobService](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-python-legacy), so will import as such.

```python
# import blob
from azure.storage.blob import BlockBlobService
```

### Run Snippet

See if this works:

```python
#Python Code
from azure.storage.blob import BlockBlobService

# Create the BlockBlockService that is used to call the Blob service for the storage account
account_name = 'your_storage_account_name'
sas_token = 'your_sas_token'
block_blob_service = BlockBlobService(account_name=account_name, 
                                      sas_token=sas_token)
container_name = 'your_blob_container_name'

# %%
# List the blobs in the container
print("\nList blobs in the container")
generator = block_blob_service.list_blobs(container_name)
for blob in generator:
    print("\t Blob name: " + blob.name)
# all 
    
```

It does work.
