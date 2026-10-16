# Lab 1 - Python project with uv and dataset generation

Repository: https://github.com/Briesmart/bigdata-repo

## Project structure

~~~
.gitignore
.python-version
README.md
pyproject.toml
src/bigdata_repo/__init__.py
src/bigdata_repo/dataset_orders.py
src/bigdata_repo/dataset_users.py
src/bigdata_repo/serialize.py
~~~

## Entry points (pyproject.toml)

~~~toml
[project.scripts]
dataset-users = "bigdata_repo.dataset_users:main"
dataset-orders = "bigdata_repo.dataset_orders:main"
~~~

## Users generation

~~~bash
uv run dataset-users -c 2 -o jsonline
~~~

~~~
{"uuid": "bdd640fb-0667-4ad1-9c80-317fa3b1799d", "username": "garzaanthony", "name": "Charles Garcia", "sex": "M", "address": "908 Jennifer Squares\nRobinsonshire, KY 01352", "mail": "helenpeterson@gmail.com", "birthdate": "1935-10-07"}
{"uuid": "17be3111-1a2a-43ed-962b-0f79c37459ee", "username": "blairamanda", "name": "Ryan Munoz", "sex": "M", "address": "Unit 6184 Box 9593\nDPO AP 09617", "mail": "stanleykendra@gmail.com", "birthdate": "2010-01-02"}
~~~

## Orders generation

~~~bash
uv run dataset-orders -u 2 -C 1 -c 2 -o json | jq '.[0]'
~~~

~~~json
{
  "uuid": "a2bc372f-7412-4293-8729-4739614ff3d7",
  "user_uuid": "bdd640fb-0667-4ad1-9c80-317fa3b1799d",
  "date": "2020-01-01 00:50:02.797536+00:00",
  "quantity": 2,
  "product": "cookie"
}
~~~

The `user_uuid` of the order matches the `uuid` of the first generated user.

## Git history

~~~
ac39d76 feat: uv project, dataset generators and lab 1
~~~
