# How to use?

- enter into kernel directory
- run
```
curl -SsL https://github.com/dpkg123/kpatch/raw/setup.sh | bash -s <config file>
```

or use github actions into your workflow file such as:

```
  - uses: dpkg123/kpatch/actions@main
    with:
      config: defconfig
```
