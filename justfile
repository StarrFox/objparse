default: add commit push

add:
    git add .

commit:
    cz commit

push:
    git push

bump:
    cz bump
    git push
    git push --tags

shell:
    poetry shell