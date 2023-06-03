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

FROM debian:bookworm-slim

ENV TERM xterm-256color

USER 1000

WORKDIR /usr/tui

COPY --from=ghcr.io/charmbracelet/gum:v0.10.0 /usr/local/bin/gum /usr/local/bin/gum
COPY --from=docker.io/mikefarah/yq:4.34.1 /usr/bin/yq /usr/bin/yq

COPY --chmod=0755 ./tui-script.sh /tui-script.sh

CMD ["/tui-script.sh"]