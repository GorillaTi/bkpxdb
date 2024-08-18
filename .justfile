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

push:
    docker push {{user}}/{{name}} --all-tags

run-it:
    docker run -it --rm \
        ecespedes/{{name}}:latest \
        bash

run:
    docker run --rm \
        -d \
        --hostname={{name}} \
        --restart=always \
        -p 3306:3306 \
        -p 5432:5232 \
        --name {{name}} \
        # --env-file .env \
        # -v ${PWD}/crontab.txt:/app/crontab.txt \
        {{user}}/{{name}}:{{version}}

sh:
    docker run --rm \
        -it \
        --name {{name}} \
        --init \
        --env-file .env \
        -v ${PWD}/crontab:/crontab \
            {{user}}/{{name}}:{{version}} \
        sh