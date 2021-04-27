FROM kalilinux/kali-rolling

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="true"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=code
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/common-debian.sh /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    # Remove imagemagick due to https://security-tracker.debian.org/tracker/CVE-2019-10131
    && apt-get purge -y imagemagick imagemagick-6-common \
    # Install common packages, non-root user
    && bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts


#安装python3(暂时选择python 3.8.9, 因为官网好像默认的是这个版本, 有很多云商python版本最高也就是python3.8.9)
COPY library-scripts/python-debian.sh /tmp/library-scripts/
ARG PYTHON_PATH=/usr/local/python
ENV PIPX_HOME=/usr/local/py-utils \
    PIPX_BIN_DIR=/usr/local/py-utils/bin
ENV PATH=${PYTHON_PATH}/bin:${PATH}:${PIPX_BIN_DIR}
COPY library-scripts/python-debian.sh /tmp/library-scripts/
RUN apt-get update && bash /tmp/library-scripts/python-debian.sh "3.8.9" "${PYTHON_PATH}" "${PIPX_HOME}"


# 这里不知道为何出错,先跳过不要
# # Setup default python tools in a venv via pipx to avoid conflicts
# ENV PIPX_HOME=/usr/local/py-utils \
#     PIPX_BIN_DIR=/usr/local/py-utils/bin
# ENV PATH=${PATH}:${PIPX_BIN_DIR}
# COPY ./library-scripts/python-debian.sh /tmp/library-scripts/
# RUN bash /tmp/library-scripts/python-debian.sh "none" "/usr/local" "${PIPX_HOME}" "${USERNAME}" \ 
#     && apt-get clean -y && rm -rf /tmp/library-scripts



# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME


ENV DEBIAN_FRONTEND noninteractive
RUN apt update && export DEBIAN_FRONTEND=noninteractive && apt install -y \
    apt-transport-https gnupg2 sudo curl wget vim ssh openssh-server iptables net-tools tree \
    ncat socat openvpn tor docker.io \    
    && apt-get autoremove -y && apt-get clean -y 




# RUN apt install --no-install-recommends -y iptables libdevmapper1.02.1 && \
#     wget -O 1.deb https://download.docker.com/linux/debian/dists/buster/pool/stable/amd64/containerd.io_1.4.4-1_amd64.deb && dpkg -i 1.deb && rm 1.deb && \
#     wget -O 1.deb https://download.docker.com/linux/debian/dists/buster/pool/stable/amd64/docker-ce-cli_20.10.5~3-0~debian-buster_amd64.deb  && dpkg -i 1.deb && rm 1.deb && \
#     wget -O 1.deb https://download.docker.com/linux/debian/dists/buster/pool/stable/amd64/docker-ce_20.10.5~3-0~debian-buster_amd64.deb && dpkg -i 1.deb && rm 1.deb && \
#     apt clean


# # 实践证明,就这样就能正常启动rdp
# # 启动命令:(可修改端口号 sed -i 's/port=3389/port=3391/g' /etc/xrdp/xrdp.ini)
# # echo xfce4-session >~/.xsession && service xrdp restart
# RUN apt-get install -y kali-desktop-xfce xorg xfce4 xrdp dbus dbus-x11 && \
#     apt clean


RUN apt-get install -y git docker-compose&& \
    apt clean

RUN wget -q https://github.com/cli/cli/releases/download/v1.9.0/gh_1.9.0_linux_amd64.deb && \
    dpkg -i gh_1.9.0_linux_amd64.deb && rm gh_1.9.0_linux_amd64.deb


RUN wget -q -O frp_0.36.2_linux_386.tar.gz https://github.com/fatedier/frp/releases/download/v0.36.2/frp_0.36.2_linux_386.tar.gz && \
        tar vxzf frp_0.36.2_linux_386.tar.gz && rm frp_0.36.2_linux_386.tar.gz && \
        sudo cp frp_0.36.2_linux_386/frpc /usr/local/bin && sudo chmod +x /usr/local/bin/frpc && \
        sudo cp frp_0.36.2_linux_386/frps /usr/local/bin && sudo chmod +x /usr/local/bin/frps && \
        rm -rdf frp_0.36.2_linux_386


# #安装python3.8 [使用 微软的 library-scripts 中的脚本来安装更好一点]
# # 注意:不要使用标准的make install，因为它会覆盖默认的系统python3二进制文件。
# # 安装完后文件在:/usr/local/bin/python3.8
# # 如果要使用python3.8作为默认版本: ln -s /usr/local/bin/python3.8 /usr/bin/python
# # sudo ln -s /usr/local/bin/pip3.8 /usr/bin/pip
# RUN apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev && \
#     apt clean && \
#     curl -O https://www.python.org/ftp/python/3.8.9/Python-3.8.9.tgz && \
#     tar -xf Python-3.8.9.tgz && \
#     cd Python-3.8.9 && ./configure --enable-optimizations && \
#     make && \
#     sudo make altinstall && \
#     cd .. && rm Python-3.8.9.tgz && rm -rdf Python-3.8.9


# ##############################################################
##  安装vscode
RUN apt install -y gnupg libgbm1 libxss1 libgtk-3-0 libnss3 libxkbfile1 libsecret-1-0 && \
    wget -O 1.deb https://go.microsoft.com/fwlink/?LinkID=760868 && \
    sudo dpkg -i 1.deb && sudo rm 1.deb && \
    apt clean


# # 实践证明,就这样就能正常启动rdp
# # 启动命令:(可修改端口号 sed -i 's/port=3389/port=3391/g' /etc/xrdp/xrdp.ini)
# # echo xfce4-session >~/.xsession && service xrdp restart
RUN apt-get install -y kali-desktop-xfce xorg xfce4 xrdp dbus dbus-x11 && \
    apt clean


RUN echo "v0.1.3" > /mtcode_version.txt
# RUN apt install -y python3-dev python3-venv

# RUN curl -sL https://deb.nodesource.com/setup_15.x | bash -&& apt-get install -y nodejs
# RUN npm install --global yarn typescript
# COPY ./bin /app
# RUN chmod 777 -R /app
# WORKDIR /app
CMD ["bash","-c","./entry"]