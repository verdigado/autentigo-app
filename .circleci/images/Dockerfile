# Installs the Android SDK build-tools 30.0.3
# so that subsequent builds do not need to install during flutter builds
# https://github.com/flutter/flutter/issues/83573
# https://github.com/flutter/flutter/issues/41462

FROM cimg/android:2024.01.1

RUN echo y | ${CMDLINE_TOOLS_ROOT}/sdkmanager "build-tools;30.0.3"
