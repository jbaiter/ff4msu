all: cpu

cpu: bin/ff4wip.sfc
	bass -arch=snes-cpu -o $< src/main.asm

clean:
	cp bin/ff4clean.sfc bin/ff4wip.sfc
