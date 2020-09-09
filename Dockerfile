FROM openjdk:8-jdk
LABEL Khanh Tran <khanhtm@vng.com.vn>

ENV ANDROID_HOME "/opt/android-sdk-linux"
ENV ANDROID_SDK_ROOT "/opt/android-sdk-linux"
ENV REPO_OS_OVERRIDE "linux"
# ENV GLIBC_VERSION "2.27-r0"
ENV PATH ${PATH}:${ANDROID_HOME}/cmdline-tools/tools/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
# default ndk
ENV ANDROID_NDK_VERSION "21.3.6528147"
ENV ANDROID_NDK_HOME ${ANDROID_HOME}/ndk/${ANDROID_NDK_VERSION}

# Install required dependencies
RUN dpkg --add-architecture i386
RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 \
	libz1:i386 zip python3 p7zip-full cmake build-essential python3-distutils python3-apt \
	librsvg2-bin graphicsmagick imagemagick

# RUN apk add --no-cache --virtual=.build-dependencies wget unzip ca-certificates bash && \
# 	wget https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub -O /etc/apk/keys/sgerrand.rsa.pub && \
# 	wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk -O /tmp/glibc.apk && \
# 	wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk -O /tmp/glibc-bin.apk && \
# 	apk add --no-cache /tmp/glibc.apk /tmp/glibc-bin.apk && \
# 	rm -rf /tmp/* && \
# 	rm -rf /var/cache/apk/*

# Download and extract Android Tools
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip -O /tmp/tools.zip && \
	mkdir -p ${ANDROID_HOME}/cmdline-tools && \
	unzip /tmp/tools.zip -d ${ANDROID_HOME}/cmdline-tools && \
	rm -v /tmp/tools.zip

# Install SDK Packages
RUN mkdir -p /root/.android/ && touch /root/.android/repositories.cfg && \
	yes | sdkmanager "--licenses" && \
	sdkmanager "--update" && \
	sdkmanager "build-tools;28.0.3" "build-tools;29.0.3" "build-tools;30.0.2" "build-tools;21.1.2" && \
    sdkmanager "cmake;3.10.2.4988404" && \
    sdkmanager "ndk;${ANDROID_NDK_VERSION}" && \
    sdkmanager "ndk;16.1.4479499" && \
    sdkmanager "platforms;android-30" "platforms;android-29" "platforms;android-21" && \
    # sdkmanager "emulator" "system-images;android-30;google_apis_playstore;x86_64" && \
    sdkmanager "platform-tools" "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository" "patcher;v4" "skiaparser;1"
RUN sdkmanager "ndk;20.1.5948944" 

# RVM & Ruby needed for fastlane below
RUN /bin/bash -l -c "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB" && \
    \curl -L https://get.rvm.io | bash -s stable && \
    /bin/bash -l -c "rvm requirements" && \
    /bin/bash -l -c "rvm install 2.5.1" && \
    /bin/bash -l -c "gem install psych" && \
    /bin/bash -l -c "gem install bundler" && \
    /bin/bash -l -c "gem install fastlane"

# install pip3
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py && rm get-pip.py && \
    pip3 install requests telegram-send pydrive pexpect pyotp
