#!/bin/bash
group=<Enter resource group name >
az group create -g $group -l < Enter resource group location >
username=<Enter any username of your choice >
password=<Enter secret password of your choice >

## Include if you wish to create a virtual network for the availibility set 
az network vnet create \
  -n vm-vnet \
  -g $group \
  -l < location > \
  --address-prefixes '10.0.0.0/16' \
  --subnet-name subnet \
  --subnet-prefixes '10.0.0.0/24'

## Create the VM Avavilability set and corresponding VMS. Here we create 3 VMs in the availability set 
az vm availability-set create \
  -n vm-as \
  -l < location > \
  -g $group

for NUM in 1 2 3
do
  az vm create \
    -n vm-0$NUM \
    -g $group \
    -l < location > \
    --size Standard_B1s \
    --image Win2019Datacenter \
    --admin-username $username \
    --admin-password $password \
    --vnet-name vm-vnet \
    --subnet subnet \
    --public-ip-address "" \
    --availability-set vm-as \
	  --nsg vm-nsg
done

## Include this if you intend to open port 80 for web hosting
for NUM in 1 2 3
do
  az vm open-port -g $group --name vm-0$NUM --port 80
done

## Include this to host a default microsoft webserver
for NUM in 1 2 3
do
  az vm extension set \
    --name CustomScriptExtension \
    --vm-name vm-0$NUM \
    -g $group \
    --publisher Microsoft.Compute \
    --version 1.8 \
    --settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'
done
