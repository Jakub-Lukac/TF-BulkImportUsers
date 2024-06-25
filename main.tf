locals {
  users      = jsondecode(file("${path.module}/users.json"))
  users_list = { for idx, user in local.users : idx => user }
}

output "users" {
  value = local.users
}

output "users_list" {
  value = local.users_list
}

# Generate random passwords for each user
resource "random_password" "users" {
  for_each = local.users_list

  length           = 16
  special          = true
  override_special = "!#@%&*()-_=+[]{}<>:?"
}

resource "azuread_user" "users" {
  for_each = local.users_list

  user_principal_name = each.value.email
  display_name        = each.value.display_name
  mail_nickname       = split("@", each.value.email)[0]
  # "jsmith@M365x25212640.OnMicrosoft.com" => [jsmith, M365x25212640.OnMicrosoft.com] => [0] = jsmith
  given_name = each.value.first_name
  surname    = each.value.last_name
  password   = random_password.users[each.key].result
}

# each.key => 0,1,2,...
# each.value => {} (object of some pre-defined parameters)



