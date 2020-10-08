output "emr_cluster_master_public_dns" {
  description = "The public DNS of the master EC2 instance."
   value   = "${aws_emr_cluster.myEmr-spark-cluster.master_public_dns}"
}

