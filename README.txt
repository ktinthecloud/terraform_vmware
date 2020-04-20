Install terraform and add the path to the terraform.exe to the environment variable path on the PC

Files inventory:

Main directory where you'll run terraform.exe from:
main.tf (main config)
terraform.tfstate (state file, keeps record of the state of your environment)
terraform.tfstate.backup
terraform.tfvars (passwords)
variables.tf (variable declartion file)

When you run "terraform init" the first time it will pull down and install the vsphere provider and put it in the .terraform directory.  This happens because the provider is called out in the main.tf file.

Terraform commands:

terraform init
terraform refresh (not always necessary)
terraform plan
terraform apply
terraform destroy

To push local repository to Azure DevOps repository:
#In the local directory from the root of the project
git init
git remote add origin <URL for Azure Git repo>
git add .
git commit -m 'initial commit'
git push -u origin master

I pulled this from my Azure DevOps Repo and my pipeline was pushing the job down to a local Azure Agent and then running the job against my local vCenter.  I also experimented with using Terraform cloud state management and storing the passwords in an Azure Vault.
