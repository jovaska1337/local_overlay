# this is stolen from https://github.com/luisbocanegra/plasma-panel-spacer-extended

cmake_minimum_required(VERSION 3.16)
set(PROJECT_NAME "applet-window-title")
project(${PROJECT_NAME})
# Use Extra CMake Modules (ECM) for common functionality.
# See http://api.kde.org/ecm/manual/ecm.7.html
# and http://api.kde.org/ecm/manual/ecm-kde-modules.7.html
find_package(ECM REQUIRED NO_MODULE)
# Needed by find_package(KF5Plasma) below.
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR} ${CMAKE_MODULE_PATH})

# Get id and version from metadata
file(READ ${CMAKE_CURRENT_SOURCE_DIR}/package/metadata.json METADATA)
string(JSON PLUGIN_ID GET ${METADATA} KPlugin Id)
string(JSON CUR_VERSION GET ${METADATA} KPlugin Version)
message("Plugin Id: ${PLUGIN_ID}")
message("Version: ${CUR_VERSION}")

# Locate plasma_install_package macro.
find_package(Plasma REQUIRED)
plasma_install_package(package org.kde.windowtitle)
