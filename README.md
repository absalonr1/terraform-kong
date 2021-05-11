# terraform-kong

Pasos manuales:

Crear key-pair en la region correspondiente y configurar nombre en var.key_pair. Guardar archivo .pem para conectarse al bastion. Instancias de Kong usan mismo key-pair (por lo que debe hacer un upload de este archivo a la VM bastion)
Crear certificado en ACM (account donde se instalara kong) 
Crear subdominio en Route53 (account prod)
Configurar listener https ALB llengo al mismo targetgroup y usando certificado creado
Generar los peering que sean necesarios (legar a VPC con EKS por ejemplo)