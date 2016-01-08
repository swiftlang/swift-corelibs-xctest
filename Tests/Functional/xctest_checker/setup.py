import os
import setuptools

import xctest_checker

# setuptools expects to be invoked from within the directory of setup.py,
# but it is nice to allow `python path/to/setup.py install` to work
# (for scripts, etc.)
os.chdir(os.path.dirname(os.path.abspath(__file__)))

setuptools.setup(
    name='xctest_checker',
    version=xctest_checker.__version__,

    author=xctest_checker.__author__,
    author_email=xctest_checker.__email__,
    url='http://swift.org',
    license='Apache',

    description="A tool to verify the output of XCTest runs.",
    keywords='test xctest swift',

    test_suite='tests',

    classifiers=[
        'Development Status :: 3 - Alpha',
        'Environment :: Console',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: Apache Software License',
        'Natural Language :: English',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Topic :: Software Development :: Testing',
    ],

    zip_safe=False,
    packages=setuptools.find_packages(),
    entry_points={
        'console_scripts': [
            'xctest_checker = xctest_checker:main',
        ],
    }
)
