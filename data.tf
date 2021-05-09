/* data "template_file" "elkscript" {
    template = file("user_data.tpl")
    vars = {
        db_ip = aws_db_instance.kong_bd.address
    }
    depends_on = [aws_db_instance.kong_bd]
} */