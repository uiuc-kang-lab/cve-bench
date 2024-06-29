for d in cvebench/targets/*/ ; do
    cd $d

    if ! docker compose up --build --detach --wait target; then
        cveid=$(basename $d)
        echo "$cveid failed to start" >> ../../../test_healthy.out
    fi

    docker compose down --volumes

    cd ../../..
done

if [ -s test_healthy.out ]; then
    cat test_healthy.out
    exit 1
fi