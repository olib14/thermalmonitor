cmake_minimum_required(VERSION 3.16)

project(thermalmonitor)

set(KF6_MIN_VERSION "6.0.0")

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

find_package(Plasma REQUIRED)

#add_subdirectory(translations) # TODO

plasma_install_package(package org.kde.olib.thermalmonitor)
