user            := "ecespedes"
name         := `basename ${PWD}`
version      := `git tag -l  | tail -n1`

default:
    @just --list

build:
    @echo {{version}}
    @echo {{name}}
    docker build -f ${PWD}/Dockerfile \
        -t {{user}}/{{name}}:{{version}} \
        -t {{user}}/{{name}}:latest \
        .

push-all:
    docker push {{user}}/{{name}} --all-tags

push-latest:
    docker push {{user}}/{{name}} :{{version}} && \
    docker push {{user}}/{{name}} :latest 

run-dev:
    docker compose -f docker-compose.dev.yml up -d

run-prod:
    docker compose -f docker-compose.yml up -d

stop-dev:
    docker compose -f docker-compose.dev.yml down

stop-prod:
    docker compose -f docker-compose.yml down

run:
    docker run --rm \
        -d \
        --name {{name}} \
        --hostname={{name}} \
        -p 3306:3306 \
        -p 5432:5232 \
        -v ./logs:/var/log/ \
        -v ./data/bkp_db/:/app/bkp_db \
        {{user}}/{{name}}:{{version}}

bash:
    docker run --rm \
        -it \
        --name {{name}} \
        -v ./logs:/var/log \
        {{user}}/{{name}}:{{version}} \
        bash