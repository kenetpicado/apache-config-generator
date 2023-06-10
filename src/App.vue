<script setup>
import { ref, computed } from 'vue'
import { useDownload } from "/src/composable/useDownload.js"

const hostname = ref('example.test')
const path = ref('/var/www/testing/public')
const { downloadFile } = useDownload();

const GREEN = "\\033[1;32m";
const RED = "\\033[1;31m";
const RESET = "\\033[0m";
const CHECK_MARK = "\\xE2\\x9C\\x94";

const functionsToPrint = `print_success() {
  echo -e "${GREEN}${CHECK_MARK} $1${RESET}"
}

print_error() {
  echo -e "${RED}✗ $1${RESET}"
}`

const configFile = computed(() => {
    return `<VirtualHost *:80>
    DocumentRoot "${path.value}"
    ServerName ${hostname.value.toLowerCase()}
    ServerAlias *.${hostname.value.toLowerCase()}
    <Directory "${path.value}">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>`
})

const scriptToDeploy = computed(() => {
    return `#!/bin/bash

${functionsToPrint}

sudo sh -c "echo '127.0.0.1    ${hostname.value}' >> /etc/hosts"
if [ $? -eq 0 ]; then
  print_success "Hostname added to /etc/hosts"
else
  echo "Failed to add hostname to /etc/hosts"
fi

sudo mv ${hostname.value}.conf /etc/apache2/sites-available/${hostname.value}.conf
if [ $? -eq 0 ]; then
  print_success "Config file moved to /etc/apache2/sites-available/"
else
  echo "Failed to move config file"
fi

sudo a2ensite ${hostname.value}.conf
if [ $? -eq 0 ]; then
  print_success "Config file enabled"
else
  echo "Failed to enable config file"
fi

sudo systemctl restart apache2
if [ $? -eq 0 ]; then
  print_success "Apache restarted"
else
  echo "Failed to restart Apache"
fi`
})

const scriptToRemove = computed(() => {
    return `#!/bin/bash

${functionsToPrint}

sudo sed -i "/127.0.0.1    ${hostname.value}/d" /etc/hosts
if [ $? -eq 0 ]; then
  print_success "Hostname removed from /etc/hosts"
else
  print_error "Failed to remove hostname from /etc/hosts"
fi

sudo a2dissite ${hostname.value}.conf
if [ $? -eq 0 ]; then
  print_success "Config file disabled"
else
  print_error "Failed to disable config file"
fi

sudo rm /etc/apache2/sites-available/${hostname.value}.conf
if [ $? -eq 0 ]; then
  print_success "Config file removed"
else
  print_error "Failed to remove config file"
fi

sudo systemctl restart apache2
if [ $? -eq 0 ]; then
  print_success "Apache restarted"
else
  print_error "Failed to restart Apache"
fi`
})

function downloadFiles() {
    downloadFile(`${hostname.value}.conf`, configFile.value)
    downloadFile(`deploy-${hostname.value}.sh`, scriptToDeploy.value)
    downloadFile(`remove-${hostname.value}.sh`, scriptToRemove.value)
}

</script>
<template>
    <div class="w-full flex my-8">
        <div class="w-full space-y-6 mx-8">

            <section class="shadow rounded-xl bg-white p-6">
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">

                    <div>
                        <div class="text-gray-500 text-xl mb-3">Apache Config Generator for Laravel</div>
                        <div class="mb-3">
                            <label class="text-gray-500 text-xs">Hostname</label>
                            <input v-model="hostname" type="text" class="input-primary" placeholder="Type the hostname">
                        </div>
                        <div class="mb-3">
                            <span class="text-gray-500 text-xs">Project path</span>
                            <input v-model="path" type="text" class="input-primary" placeholder="Type the path">
                        </div>

                        <div class="text-gray-500 text-xl my-3">Instructions</div>
                        <div class="text-xs text-gray-500 leading-relaxed">
                            <ul class="space-y-2 list-disc list-inside">
                                <li>Download Files</li>
                                <li>sudo chmod u+x {{ `deploy-${hostname}.sh` }}</li>
                                <li>sudo ./{{ `deploy-${hostname}.sh` }}</li>
                                <li>Access to <a :href="`http://${hostname}`" class="text-gray-800"
                                        target="_blank">http://{{ hostname }}</a></li>
                                <li>Enjoy your development!</li>
                            </ul>
                        </div>

                        <button @click="downloadFiles()" class="btn-primary mt-4">Download Files</button>
                    </div>

                    <!-- PREVIEW FILES -->
                    <div class="col-span-2 w-full">
                        <button class="mb-3">
                            <span class="badge-primary">
                                {{ hostname }}.conf
                            </span>
                        </button>
                        <div class="p-4 bg-gray-100 rounded-xl text-sm">
                            <pre>{{ configFile }}</pre>
                        </div>
                        <button class="mt-6 mb-3">
                            <span class="badge-primary">
                                deploy-{{ hostname }}.sh
                            </span>
                        </button>
                        <div class="p-4 bg-gray-100 rounded-xl text-sm">
                            <pre>{{ scriptToDeploy }}</pre>
                        </div>
                        <button class="mt-6 mb-3">
                            <span class="badge-primary">
                                remove-{{ hostname }}.sh
                            </span>
                        </button>
                        <div class="p-4 bg-gray-100 rounded-xl text-sm">
                            <pre>{{ scriptToRemove }}</pre>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </div>
</template>
