# --- compute/main.tf ---

data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "random_id" "mtc_node_id" {
  byte_length = 2
  count       = var.instance_count
}

resource "aws_key_pair" "mtc-key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "mtc_node" {
  count         = var.instance_count
  instance_type = var.instance_type
  key_name      = aws_key_pair.mtc-key.key_name
  ami           = data.aws_ami.server_ami.id
  user_data = templatefile(var.user_data_path, {
    nodename    = "mtc-${random_id.mtc_node_id[count.index].dec}"
    db_endpoint = var.db_endpoint
    dbuser      = var.dbuser
    dbpass      = var.dbpassword
    dbname      = var.dbname
  })
  vpc_security_group_ids = [var.public_sg]
  subnet_id              = var.public_subnets[count.index]
  root_block_device {
    volume_size = var.vol_size
  }
  tags = {
    Name = "mtc_node-${random_id.mtc_node_id[count.index].dec}"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file(var.private_key_path)
    }
    script = "${path.cwd}/delay.sh"
  }
  provisioner "local-exec" {
    command = templatefile("${path.cwd}/scp_script.tpl", {
      nodeip   = self.public_ip
      k3s_path = "${path.cwd}/../"
      nodename = self.tags["Name"]
    })
  }
  provisioner "local-exec" {
      when = destroy
      command = "rm -f ${path.cwd}/../k3s-${self.tags.Name}.yml"
  }
}

resource "aws_lb_target_group_attachment" "mtc_tg_attach" {
  count            = var.instance_count
  target_group_arn = var.lb_target_group_arn
  target_id        = aws_instance.mtc_node[count.index].id
  port             = var.tg_port
}