echo "source me...."
source ../z03-openrc-v3.sh
export TF_VAR_username=$OS_USERNAME
export TF_VAR_password=$OS_PASSWORD
export TF_VAR_tenant=$OS_PROJECT_NAME

export PKR_VAR_username=$OS_USERNAME
export PKR_VAR_password=$OS_PASSWORD
export PKR_VAR_tenant=$OS_PROJECT_NAME

# just to test we're in

openstack server list
