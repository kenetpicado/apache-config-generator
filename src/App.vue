<script setup>
import { ref, computed } from 'vue'
import { useDownload } from "/src/composable/useDownload.js"

const hostname = ref('example.test')
const path = ref('/var/www/testing/public')
const { downloadFile } = useDownload();

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
sudo echo "127.0.0.1    ${hostname.value}" >> /etc/hosts
echo "Hostname added to /etc/hosts"

sudo mv ${hostname.value}.conf /etc/apache2/sites-available/${hostname.value}.conf
echo "Config file moved to /etc/apache2/sites-available/"

sudo a2ensite ${hostname.value}.conf
echo "Config file enabled"

sudo systemctl restart apache2
echo "Apache restarted"`
})

const scriptToRemove = computed(() => {
    return `#!/bin/bash
sudo sed -i "/127.0.0.1    ${hostname.value}/d" /etc/hosts
echo "Hostname removed from /etc/hosts"

sudo a2dissite ${hostname.value}.conf
echo "Config file disabled"

sudo rm /etc/apache2/sites-available/${hostname.value}.conf
echo "Config file removed"

sudo systemctl restart apache2
echo "Apache restarted"`
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
                                <li>Access to <a :href="`http://${hostname}`" class="text-gray-800" target="_blank">http://{{ hostname }}</a></li>
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
