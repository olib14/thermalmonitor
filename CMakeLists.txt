cmake_minimum_required(VERSION 3.16)

project(thermalmonitor)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

find_package(KF6 REQUIRED COMPONENTS
    Plasma
)

#add_subdirectory(translations) # TODO

plasma_install_package(package org.kde.olib.thermalmonitor)
