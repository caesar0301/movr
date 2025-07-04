# Build shared library using cmake (handled by configure script)
# This ensures the library is available for R package installation
all: 
	@echo "Library built by configure script"
	@if [ ! -f ../libs/movr.so ]; then \
		echo "Error: movr.so not found in ../libs/"; \
		exit 1; \
	fi
	@if [ ! -f movr.so ]; then \
		echo "Copying movr.so to src directory"; \
		cp ../libs/movr.so .; \
	fi

clean:
	rm -rf ../build ../libs/movr.so movr.so
