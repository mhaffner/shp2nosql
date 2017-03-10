if type esbulk >/dev/null 2>&1
then
    esbulk_installed=true
else
    esbulk_installed=false
fi

echo $esbulk_installed
