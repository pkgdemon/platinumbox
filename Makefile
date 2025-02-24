# Makefile

check_root:
	@if [ $$(id -u) -ne 0 ]; then \
		echo "This Makefile must be run as root or with sudo."; \
		exit 1; \
	fi

install: check_root
	@if [ -d "/System" ]; then \
	  echo "System appears to be already installed."; \
	  exit 0; \
	else \
	  WORKDIR=`pwd`; \
	  mkdir -p /System/Library; \
	  cp -R Library/* /System/Library; \
	  . /System/Library/Preferences/GNUstep.conf; \
	  CPUS=`nproc`; \
	  export GNUSTEP_INSTALLATION_DOMAIN="SYSTEM"; \
	  echo "CPUS is set to: $$CPUS"; \
	  echo "SYSTEM is set to: $$GNUSTEP_INSTALLATION_DOMAIN"; \
	  echo "WORKDIR is set to: $$WORKDIR"; \
	  cd $$WORKDIR/tools-make && ./configure \
	    --enable-importing-config-file \
	    --with-config-file=/System/Library/Preferences/GNUstep.conf \
	    --with-library-combo=ng-gnu-gnu \
	  && gmake || exit 1 && gmake install; \
	  . /System/Library/Makefiles/GNUstep.sh; \
	  mkdir -p $$WORKDIR/libobjc2/Build; \
	  cd $$WORKDIR/libobjc2/Build && pwd && ls && cmake .. \
	    -DGNUSTEP_INSTALL_TYPE=SYSTEM \
	    -DCMAKE_BUILD_TYPE=Release \
	    -DCMAKE_C_COMPILER=clang \
	    -DCMAKE_CXX_COMPILER=clang++; \
	  gmake -j"${CPUS}" || exit 1; \
	  gmake install; \
	  cd $$WORKDIR/libs-base && ./configure --with-installation-domain=SYSTEM && gmake -j"${CPUS}" || exit 1 && gmake install; \
	  cd $$WORKDIR/libs-gui && ./configure && gmake -j"${CPUS}" || exit 1 || exit 1 && gmake install; \
	  cd $$WORKDIR/libs-back && export fonts=no && ./configure && gmake -j"${CPUS}" || exit 1 && gmake install; \
	  cd $$WORKDIR/apps-gworkspace && ./configure && gmake && gmake install; \
          cd $$WORKDIR/plugins-themes-nesedahrik/NesedahRik.theme && gmake && gmake install; \
	fi;

uninstall: check_root
	@removed=""; \
	if [ -d "/System" ]; then \
	  rm -rf /System; \
	  removed="/System"; \
	  echo "Removed /System"; \
	fi; \
	if [ -d "/Local" ]; then \
	  rm -rf /Local; \
	  removed="$$removed /Local"; \
	  echo "Removed /Local"; \
	fi; \
	if [ -n "$$removed" ]; then \
	  echo "Uninstallation complete: $$removed"; \
	else \
	  echo "YellowBox appears to be already uninstalled. Nothing was removed."; \
	fi
