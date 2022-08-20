#### Objectives
Create  the necessary infrastructure using AWS AKS to deploy Kubernetes Pods for various services to scale a containerized application, using best practice networking and security architecture.


#### Infrastructure Layer Architecture Diagram

![AWS Architecture Diagram](/infra_layer_architecture.jpg)

This infrastructure uses a two layered architecture as shown in diagram below. Only the code for the kubernetes layer shown is included. This layer is to be deplyed only after the infrastructure layer has been deployed.
![Terraforming example Design Architecture Diagram](/architecture_design.jpg)

#### PLEASE READ BEFORE DEPLOYMENT
1. Only deploy in a region with at least 3 availability zones ( 3AZ's).  This is because of the current network architecture. 
2. Make a copy of folder called  `setup_template/MAKE_COPY_BEFORE_EDIT` into  `setups_LIVE` before deploying. Do not edit the template forder directly without making a copy
3. Any unused setups that are not live can be moved to setups_OFFLINE after destruction of both infra and kubernetes layers.
4. Quick Deployment and destruction instructions can be found here: Not Available in public domain
5. More detailed design information and other guides can be found here:
Not Available in public domain
6. Ensure you destroy the kubernetes layer for any deployment before destroying the infra layer. Not doing this in order may lead to stray artifcats in AWS that will require manual deletion.
