#!/usr/bin/env bash

# Autor:  Edmundo Cespedes A.
# Licencia: MIT
# NOMBRE: run.sh
# Version: 1.0.0
# FUNSION:
# Configura  la hora de ejecucion del script  de copia de seguridad de las de bases de
# datos MYSQL MariaDn y PosrgreSQL

# Copyright (c) 2024 Edmundo Cespedes A. <a.k.a. eksys>

# This software is provided under the MIT License.

# You can obtain a copy of the license at https://opensource.org/licenses/MIT

# In summary, you are permitted to use, copy, modify, merge, publish, distribute, 
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
#  is furnished to do so, subject to the following conditions:

# You must include this copyright notice and this license in all copies or substantial 
# portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
# OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER

# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# Exit if any command fails
set -eou pipefail

LOGS="/var/log/cron/cron.log"

{
    echo "Actualizando crontab";
    cp /app/crontab/crontab /etc/cron.d/bkpxdb-cron;
    chown root:root /etc/cron.d/bkpxdb-cron;
    chmod 644 /etc/cron.d/bkpxdb-cron ;

    echo "Starting crond... $(date)"
    service cron  restart 
} >> "$LOGS" 2>&1