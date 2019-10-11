resource "null_resource" "example2" {
  provisioner "local-exec" {
    command     = "Get-Date > completed.txt"
    interpreter = ["PowerShell", "-Command"]
  }
}
