echo "source me...."

source ./z03-openrc.sh

export PKR_VAR_username=$OS_USERNAME
export PKR_VAR_password=$OS_PASSWORD
export PKR_VAR_tenant=$OS_PROJECT_NAME


# we need to get the latest images and set them as env vars for terraform

export TF_VAR_username=$OS_USERNAME
export TF_VAR_password=$OS_PASSWORD
export TF_VAR_tenant=$OS_PROJECT_NAME

# Get latest image information
echo "Finding latest images..."
chmod +x "./scripts/get_latest_images.py"
eval $("./scripts/get_latest_images.py")

echo "Using server image: $SERVER_IMAGE_NAME ($SERVER_IMAGE_ID)"
echo "Using worker image: $WORKER_IMAGE_NAME ($WORKER_IMAGE_ID)"

# by putting these here we don't have to use the deploy.sh script to
# build, we can just "terraform apply"
export TF_VAR_server_image_id=$SERVER_IMAGE_ID
export TF_VAR_worker_image_id=$WORKER_IMAGE_ID

# just to test we're in
openstack server list
