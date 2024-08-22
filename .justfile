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

run-d:
    docker run  --rm \
        -d \
        --name {{name}} \
        -v ./logs:/var/log/ \
        -v ./data/bkp_db/:/home/{{name}}/bkp_db \
        {{user}}/{{name}}:{{version}}

run:
    docker run \
        -d \
        --name {{name}} \
        #--hostname={{name}} \
        #--restart=always \
        # -p 3306:3306 \
        # -p 5432:5232 \
        # # --env-file .env \
        -v ./logs:/var/log \
        {{user}}/{{name}}:latest

bash:
    docker run --rm \
        -it \
        --name {{name}} \
        -v ./logs:/var/log \
        {{user}}/{{name}}:{{version}} \
        bash