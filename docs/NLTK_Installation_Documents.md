# Installing NLTK

NLTK requires Python versions 3.8, 3.9, 3.10, 3.11 or 3.12.

## Setting up a Python Environment (Mac/Unix/Windows)

Please go through this guide to learn how to manage your virtual environment managers before you install NLTK, https://docs.python-guide.org/dev/virtualenvs/

Alternatively, you can use the Anaconda distribution installer that comes “batteries included” https://www.anaconda.com/distribution/

## Mac/Unix

Install NLTK: run `pip install --user -U nltk`

Install Numpy (optional): run `pip install --user -U numpy`

Test installation: run `python3` then type `import nltk`

For older versions of Python it might be necessary to install setuptools (see https://pypi.python.org/pypi/setuptools) and to install pip (sudo easy_install pip).

## Installing NLTK Data

After installing the NLTK package, please do install the necessary datasets/models for specific functions to work.

If you’re unsure of which datasets/models you’ll need, you can install the “popular” subset of NLTK data, on the command line type python -m nltk.downloader popular, or in the Python interpreter import nltk; nltk.download('popular')


## Installing NLTK Data

NLTK comes with many corpora, toy grammars, trained models, etc. A complete list is posted at: https://www.nltk.org/nltk_data/

To install the data, first install NLTK (see https://www.nltk.org/install.html), then use NLTK’s data downloader as described below.

Apart from individual data packages, you can download the entire collection (using “all”), or just the data required for the examples and exercises in the book (using “book”), or just the corpora and no grammars or trained models (using “all-corpora”).

## Interactive installer

For central installation on a **multi-user machine**, do the following from an administrator account.

Run the Python interpreter and type the commands:

```python
>>> import nltk
>>> nltk.download()
```

A new window should open, showing the NLTK Downloader. Click on the File menu and select Change Download Directory. For central installation, set this directory to /usr/local/share/nltk_data (Mac), or /usr/share/nltk_data (Unix). Next, select the packages or collections you want to download.

If you did not install the data to one of the above central locations, you will need to set the NLTK_DATA environment variable to specify the location of the data.

Test that the data has been installed as follows. (This assumes you downloaded the Brown Corpus):

```python
>>> from nltk.corpus import brown
>>> brown.words()
['The', 'Fulton', 'County', 'Grand', 'Jury', 'said', ...]
```

## Installing via a proxy web server

If your web connection uses a proxy server, you should specify the proxy address as follows. In the case of an authenticating proxy, specify a username and password. If the proxy is set to None then this function will attempt to detect the system proxy.

```python
>>> nltk.set_proxy('http://proxy.example.com:3128', ('USERNAME', 'PASSWORD'))
>>> nltk.download()
```

## Command line installation

The downloader will search for an existing nltk_data directory to install NLTK data. If one does not exist it will attempt to create one in a central location (when using an administrator account) or otherwise in the user’s filespace. If necessary, run the download command from an administrator account, or using sudo. The recommended system location is /usr/local/share/nltk_data (Mac); and /usr/share/nltk_data (Unix). You can use the -d flag to specify a different location (but if you do this, be sure to set the NLTK_DATA environment variable accordingly).

Run the command `python -m nltk.downloader all` to ensure central installation, or `python -m nltk.downloader -d /usr/local/share/nltk_data all` to specify a different location.

Test the installation: Check that the user environment and privileges are set correctly by logging in to a user account, starting the Python interpreter, and accessing the Brown Corpus (see the previous section).

Manual installation

Create a folder nltk_data, e.g. /usr/local/share/nltk_data, and subfolders chunkers, grammars, misc, sentiment, taggers, corpora, help, models, stemmers, tokenizers.

Download individual packages from https://www.nltk.org/nltk_data/ (see the “download” links). Unzip them to the appropriate subfolder. For example, the Brown Corpus, found at: https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/corpora/brown.zip is to be unzipped to nltk_data/corpora/brown.

Set your NLTK_DATA environment variable to point to your top level nltk_data folder.