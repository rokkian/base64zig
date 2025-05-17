# base64zig
Simple educative project implamentation of a base64 in Zig


---
## Comandi utili:

- Compilare e creare l'eseguibile binario
```bash
zig build
zig build --fetch # Salva ricorsivamente le dipendenze
```

- Importare dipendenze:
```bash
zig fetch --save git+https://github.com/rockorager/zeit.git
zig fetch --save https://example.com/andrewrk/fun-example-tool/archive/refs/heads/master.tar.gz
```

## Importare 

```bash
zig fetch --save git+https://github.com/rockorager/zeit.git
zig fetch --save https://example.com/andrewrk/fun-example-tool/archive/refs/heads/master.tar.gz

# Modifcare il build.zig e aggiungere l'importazione della dipendenza

