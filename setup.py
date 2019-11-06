from setuptools import setup
import os

INSTALL_REQUIRES = open('requirements.txt').read().split('\n')[1:]

os.system('./src/_XORList/XORList/build.sh')

def main():
    setup(
        use_scm_version={"write_to": "src/_XORList/_version.py"},
        setup_requires=["setuptools-scm", "setuptools>=40.0"],
        package_dir={"": "src"},
        extras_require={
            "testing": [
                "pytest"
                "hypothesis",
            ]
        },
        install_requires=INSTALL_REQUIRES,
    )


if __name__ == "__main__":
    main()