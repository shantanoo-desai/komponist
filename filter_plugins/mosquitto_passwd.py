# Komponist - Generate Your Favourite Compose Stack With the Least Effort
#
# Copyright (C) 2023  Shantanoo "Shan" Desai <sdes.softdev@gmail.com>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published
#   by the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.
# 
# mosquitto_passwd.py: Custom Jinja2 filter plugin to generate valid PBKDF2_SHA512
#                      hash digests for plain-text passwords in `users` file for 
#                      Eclipse Mosquitto Broker


from ansible.errors import AnsibleError

def mosquitto_passwd(passwd):
    try:
        import passlib.hash
    except Exception as e:
        raise AnsibleError('mosquitto_passlib custom filter requires the passlib pip package installed')
    
    SALT_SIZE = 12
    ITERATIONS = 101

    digest = passlib.hash.pbkdf2_sha512.using(salt_size=SALT_SIZE, rounds=ITERATIONS) \
                                        .hash(passwd) \
                                        .replace("pbkdf2-sha512", "7") \
                                        .replace(".", "+")
    
    return digest + "=="


class FilterModule(object):
    def filters(self):
        return {
            'mosquitto_passwd': mosquitto_passwd,
        }
