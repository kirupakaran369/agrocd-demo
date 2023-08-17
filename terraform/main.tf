resource "eksctl_cluster" "primary" {
  eksctl_bin = "eksctl-dev"
  name = "existingvpc2"
  region = "us-east-2"
  api_version = "eksctl.io/v1alpha5"
  version = "1.16"
  vpc_id = module.vpc.vpc_id
  revision = 1
  spec = <<-EOS
  nodeGroups:
  - name: ng2
    instanceType: m5.large
    desiredCapacity: 1
    securityGroups:
      attachIDs:
      - ${aws_security_group.public_alb_private_backend.id}

  iam:
    withOIDC: true
    serviceAccounts: []

  vpc:
    cidr: "${module.vpc.vpc_cidr_block}"       # (optional, must match CIDR used by the given VPC)
    subnets:
      # must provide 'private' and/or 'public' subnets by availability zone as shown
      private:
        ${module.vpc.azs[0]}:
          id: "${module.vpc.private_subnets[0]}"
          cidr: "${module.vpc.private_subnets_cidr_blocks[0]}" # (optional, must match CIDR used by the given subnet)
        ${module.vpc.azs[1]}:
          id: "${module.vpc.private_subnets[1]}"
          cidr: "${module.vpc.private_subnets_cidr_blocks[1]}"  # (optional, must match CIDR used by the given subnet)
        ${module.vpc.azs[2]}:
          id: "${module.vpc.private_subnets[2]}"
          cidr: "${module.vpc.private_subnets_cidr_blocks[2]}"   # (optional, must match CIDR used by the given subnet)
      public:
        ${module.vpc.azs[0]}:
          id: "${module.vpc.public_subnets[0]}"
          cidr: "${module.vpc.public_subnets_cidr_blocks[0]}" # (optional, must match CIDR used by the given subnet)
        ${module.vpc.azs[1]}:
          id: "${module.vpc.public_subnets[1]}"
          cidr: "${module.vpc.public_subnets_cidr_blocks[1]}"  # (optional, must match CIDR used by the given subnet)
        ${module.vpc.azs[2]}:
          id: "${module.vpc.public_subnets[2]}"
          cidr: "${module.vpc.public_subnets_cidr_blocks[2]}"   # (optional, must match CIDR used by the given subnet)
  EOS
}


##### compaine the below config file ####

---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: common-cluster ## need to change
  region: eu-west-1
  version: "1.27"
  tags:
# secretsEncryption:
#   # ARN of the KMS key
#   keyARN: 
iam:
  # serviceRoleARN: "arn:aws:iam:::role/eks-managed-role"
  withOIDC: true
  serviceAccounts:
    - metadata:
         name: s3-reader
         namespace: default
         labels: {aws-usage: "application"}
      attachPolicyARNs:
        - "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    - metadata:
         name: aws-load-balancer-controller
         namespace: kube-system
      wellKnownPolicies:
        awsLoadBalancerController: true
    - metadata:
         name: ebs-csi-controller-sa
         namespace: kube-system
      wellKnownPolicies:
         ebsCSIController: true
    # - metadata:
    #     name: efs-csi-controller-sa
    #     namespace: kube-system
    #   wellKnownPolicies:
    #     efsCSIController: true
    # - metadata:
    #     name: cert-manager
    #     namespace: cert-manager
      # wellKnownPolicies:
      #   certManager: true
    - metadata:
        name: cluster-autoscaler
        namespace: kube-system
        labels: {aws-usage: "cluster-ops"}
      wellKnownPolicies:
        autoScaler: true
    - metadata:
        name: build-service
        namespace: ci-cd
      wellKnownPolicies:
        imageBuilder: true
    - metadata:
        name: autoscaler-service
        namespace: kube-system
      attachPolicy: # inline policy can be defined along with `attachPolicyARNs`
        Version: "2012-10-17"
        Statement:
        - Effect: Allow
          Action:
          - "autoscaling:DescribeAutoScalingGroups"
          - "autoscaling:DescribeAutoScalingInstances"
          - "autoscaling:DescribeLaunchConfigurations"
          - "autoscaling:DescribeTags"
          - "autoscaling:SetDesiredCapacity"
          - "autoscaling:TerminateInstanceInAutoScalingGroup"
          - "ec2:DescribeLaunchTemplateVersions"
          Resource: '*'
vpc:
  id: "vpc-010e469fe115f42fc"  # (optional, must match VPC ID used for each subnet below) ## need to change
  securityGroup: "" ## need to change all traffic allow not ssh allow 
  #cidr: "10.13.0.0/18"       # (optional, must match CIDR used by the given VPC)
  subnets:
    # must provide 'private' and/or 'public' subnets by availibility zone as shown
    private:
      eu-west-1a:
        id: "subnet-" ## need to change
      #  cidr: "10.13.8.0/21" # (optional, must match CIDR used by the given subnet)
      eu-west-1b:
        id: "subnet ## need to change
       # cidr: "10.13.16.0/21"  # (optional, must match CIDR used by the given subnet)
    public: # for practice only don't use public subnet for node-group
      eu-west-1a:
        id: "subnet-
      eu-west-1b:
        id: "subnet-
      # eu-west-1c:
      #   id: "subnet-062fa21ff1a5ab5d0"
      #   cidr: "143.0.80.0/20"   # (optional, must match CIDR used by the given subnet)
  clusterEndpoints:
    privateAccess: true
    publicAccess: true
  # publicAccessCIDRs:
addons:
  - name: vpc-cni # no version is specified so it deploys the default version
    version: latest
    attachPolicyARNs:
      - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
  - name: coredns
    version: latest # auto discovers the latest available
  - name: kube-proxy
    version: latest
  - name: aws-ebs-csi-driver
    version: latest
  # - name: kubecost_kubecost
  #   version: latest
    # version: v1.98.0-eksbuild.1
  # - name: upbound_universal-crossplane
  #   version: latest
 
cloudWatch:
      clusterLogging:
          # enable specific types of cluster control plane logs
          enableTypes: ["api", "audit", "authenticator", "controllerManager", "scheduler"]
          # all supported types: "api", "audit", "authenticator", "controllerManager", "scheduler"
          # supported special values: "*" and "all"
managedNodeGroups:
  - name: common-nodegroup ## need to change
    ssh:
      allow: true
      publicKeyName: win-test ## need to change
      enableSsm: true
    volumeSize: 30
    volumeType: gp3
    # volumeEncrypted: true
    # volumeKmsKeyID: 
    amiFamily: "AmazonLinux2"
    #containerRuntime: containerd
    instanceType: t3.medium
    desiredCapacity: 2
    privateNetworking: true
    tags:
    # EC2 tags 
        Function: "Kubernetes"
        # k8s.io/cluster-autoscaler/enabled: "true"
        # k8s.io/cluster-autoscaler/cluster-13: "owned"
    iam:
      #instanceRoleARN: arn:aws:iam::163516766862:role/gisc-cop-development-karpenter
      attachPolicyARNs:
        - arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
        - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
        - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
        - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
      withAddonPolicies:
        imageBuilder: true
        externalDNS: true
        certManager: true
        albIngress: true
        cloudWatch: true
        appMesh: true
        autoScaler: true
        ebs: true
        efs: true
        xRay: true
    subnets:
      - subnet-