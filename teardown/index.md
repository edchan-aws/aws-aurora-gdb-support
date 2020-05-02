# Environment Teardown

This page containers instructions to teardown and delete the resources created by the workshop. If you have run this workshop on your own AWS account, remember to follow these steps to delete all resources in order to avoid any lingering resources to be metered and billed.

## Definitions

??? tip "At an official AWS event?"
    For most AWS-sponsored events and workshops, if you have been provided a temporary AWS account environment. These steps are not necessary.

## Workshop Cost Estimates



## teardown
1. remove cloudwatch metrics
2. promote all db clusters and remove from global db cluster
3. delete 2nd region aurora db manually; do not create final snapshots
4. remove cfn 2nd region (ec2, vpc)
5. remove cfn 1st region (ec2, vpc, primary cluster)

## Remove CloudWatch Metrics

>  **`Region 2 (Secondary)`**

1. Open <a href="https://console.aws.amazon.com/rds" target="_blank">RDS</a> in the AWS Management Console. Ensure you are in your assigned region.

## Remove Aurora Global Database

1. Depending on whether you have worked on the optional module of Failback or not, and depending on where you stopped, your DB cluster and DB instance names may be different. However, the gist of this step is to remove all linkage of Aurora Global Database clusters before we decommission the Aurora DB instances individually.

1. Open <a href="https://console.aws.amazon.com/rds" target="_blank">RDS</a> in the AWS Management Console. Ensure you are in your assigned region.

1. Within the RDS console, select **Databases** on the left menu. This will bring you to the list of Databases already deployed. You should see **gdb1-cluster** and **gdb1-node1**.

1. Select **gdb1-cluster**. Click on the **Actions** menu, and select **Add Region**.
    <span class="image">![GDB Add Region](gdb-add-region1.png)</span>

1. You are now creating an Aurora Global Database, adding a new region DB cluster to be replicated from your primary region's Aurora DB cluster.

   1. Under **Global database identifier**. We will name our Global database as ``auroralabs-gdb``

   1. For **Secondary Region**, use the drop down list and select your assigned secondary region **`Region 2 (Secondary)`**. This can take a few seconds to load.

   1. Next, we have **DB Instance Class**. Aurora allows replicas and Global Database instances to be of different instance class and size. We will leave this as the default ``db.r5.large``.
     <span class="image">![GDB Settings 1](gdb-settings1.png)</span>

   1. For **Multi-AZ deployment**, we will leave this as the default value ``Don't create an Aurora Replica``. For production, it is highly recommended to scale your read traffic to multiple reader nodes for even higher availability.

   1. For **Virtual Private Cloud**, we will click on the drop down list, and select ``gdb2-vpc``. This is the dedicated VPC we created from CloudFormation for the secondary region.

   1. Expand on **Additional connectivity configuration** for more options.

   1. Under **Existing VPC security groups**, we will click on the drop down list, <span style="color:red;">deselect</span> ``default`` and <span style="color:green;">select</span> ``gdb2-mysql-internal``. Attaching this security group allows our applications in the secondary region to reach the Aurora secondary DB Cluster.
     <span class="image">![GDB Settings 2](gdb-settings2.png)</span>
      
    !!! warning "Be sure you have the proper VPC selected!" 

   1. Leave the other default options, scroll down to bottom of the page and expand on **Additional configuration**.

   1. For **DB instance identifier**, we will name the Aurora DB instance for the secondary region. Let's name this ``gdb2-node1``

   1. Similarly, under **DB cluster identifier**, we will name the Aurora DB cluster for the secondary region. Let's name this ``gdb2-cluster``

   1. Ensure the **DB cluster parameter group** and **DB parameter groups** are set to the ones with the ``gdb2-`` prefix.
     <span class="image">![GDB Settings 3](gdb-settings3.png)</span>

   1. Near the bottom, under **Monitoring**, select the checkbox for **Enable Enhanced Monitoring**. We will vend metrics down to ``60-second`` **Granularity**. Click on the drop-down menu and change **Monitoring Role** to the IAM role you have under ``gdb2-monitor-<xx-region-x>`` name.
     <span class="image">![GDB Settings 4](gdb-settings4.png)</span>
  
    !!! warning "Please validate and review all settings before moving on" 
        Before moving on, please re-validate all your settings, anything that's not explicitly called out in the instructions here can be left on the default values. Remember, some database settings and configurations are immutable after creation. 
   
   1. After confirming carefully that we have everything in order, press the **Add Region** button.

   1. You will then be returned to the main RDS console and see that the Aurora DB Cluster and DB Instance in your secondary region is being provisioned. This will take about 15-20 minutes and the Secondary DB cluster and new DB instance reader will report as *Available*. You can move on to the next step while this is still being created.
  <span class="image">![GDB Settings 5](gdb-settings5.png)</span>


## Checkpoint

At this point, you have created the Global Database, expanded the Aurora DB cluster from your primary region to replicate data over to the secondary region.

![Global Database Creation Architecture Diagram](gdb-arch.png)
