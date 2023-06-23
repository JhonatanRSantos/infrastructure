ENV=${INFRA_ENV}

lint:
	@terraform -chdir=./ fmt -recursive

deploy:
# 	Init terraform and set the backend configuration. This configuration define where it should save the .tfsatet
	@terraform -chdir=./ init -backend=true -backend-config="./backend/backend.${ENV}.hcl"
# 	Apply all changes based on the vars provided by .tfvars
	@terraform -chdir=./ apply -var-file="./env/terraform.${ENV}.tfvars"

rollback:
	@terraform -chdir=./ state push ./states/terraform.${ENV}.tfsatet

destroy:
	@terraform -chdir=./ destroy -var-file="./env/terraform.${ENV}.tfvars"