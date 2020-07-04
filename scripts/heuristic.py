import os
import re
import json
from glob import glob

# Searching pattern in string using regular expression
def re_search( pattern, text ):
    m = re.search(pattern, text)
    if m:
        return m.group(0)
    return ''

def is_derived(nifti_dir):
    try:
        jsonfile = glob( os.path.join( nifti_dir, '*.json' ) )[0]
        with open(jsonfile, 'r') as ff:
            data = json.load(ff)
            return data["ImageType"][0] != "ORIGINAL"
    except:
        return False

def infotodict(scan):
    t1    = 'ANAT_T1w'
    t2    = 'ANAT_T2w'
    rest  = 'FUNC_rest'
    fmap  = 'FMAP'
    dwi   = 'DWI_{acq}'

    series_desc = "" if not scan.series_description else scan.series_description.lower()

    t1list = ['t1', 'mprage', 'scout', 'mp2rage']
    # MPR is a derivative image
    if any(x in series_desc for x in t1list): # and not series_desc.endswith('mpr'):
        return t1
        
    if 't2' in series_desc:
        return t2

    if 'rest' in series_desc:
        return rest

    if 'fieldmap' in series_desc:
        return fmap
            
    # DWI
    sequences = ['dmri', 'multishell', 'dsi', 'hardi', 'dti', 'b0']
    if any( word in series_desc for word in sequences):
        desc = re.split('[_ ]', series_desc)[0]
        direc = re_search(r'dir\d+', series_desc)
        dirPH = re_search(r'(?<=_)(pa|ap)', series_desc).upper()
        acq = desc
        return dwi.format(acq=acq)
    