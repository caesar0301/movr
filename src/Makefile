# Build shared library using cmake (handled by configure script)
# This ensures the library is available for R package installation
all: 
	@echo "Library built by configure script"
	@if [ ! -f movr.so ]; then \
		echo "Error: movr.so not found in src directory"; \
		exit 1; \
	fi

clean:
	rm -rf ../build movr.so
