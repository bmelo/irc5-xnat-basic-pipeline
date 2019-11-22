#!/usr/bin/python
import argparse
import sys
import os
import xnat
import subprocess
import shutil
import zipfile
from glob import glob
from heuristic import infotodict, is_derived

def str2bool(v):
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

def app_args():
    parser = argparse.ArgumentParser(description='XNAT deface')
    parser.add_argument('--input', help='Input data', required=True)
    parser.add_argument('--session', help='Session', default=os.getenv('XNAT_SESSION'))
    parser.add_argument('--host', help='Server for XNAT connection', default=os.getenv('XNAT_HOST'))
    parser.add_argument('--user', help='Username for XNAT connection', default=os.getenv('XNAT_USER'))
    parser.add_argument('--passwd', help='Password for XNAT connection', default=os.getenv('XNAT_PASS'))
    parser.add_argument('--remove-dicoms', type=str2bool, help='Remove DICOM folders?', default=True)
    parser.add_argument('--save-nifti', type=str2bool, help='Save NIFTI files?', default=True)
    parser.add_argument('--rename-types', type=str2bool, help='Rename scans types?', default=True)
    parser.add_argument('--deface', type=str2bool, help='Deface anatomical images?', default=True)
    return parser.parse_args()

def download_scan(scan):
    scan.download_dir("/tmp".format(scan.id))
    dicoms = sorted( glob( '/tmp/*/scans/{}*/*/*/files/*.dcm'.format(scan.id) ) )
    if dicoms:
        return os.path.dirname( dicoms[0] )

def main():
    args = app_args()

    # Getting experiment data
    sess = xnat.connect(args.host, args.user, args.passwd)
    experiment = sess.experiments[args.session]

    # Checking each scan
    for scan in experiment.scans.values():
        bidsname = infotodict(scan)
        print( '{} - {} ({}) | bidsname: {}'.format(scan.id, scan.type, scan.series_description, bidsname))
        is_anat = str(bidsname).startswith('ANAT')
        scan_dir = download_scan(scan)

        # Converting and saving NIFTI files
        if args.save_nifti or (args.deface and is_anat):            
            # DICOM files not found
            if not os.path.isdir(scan_dir):
                continue

            nifti_dir = '/tmp/{}'.format(scan.id)
            os.mkdir(nifti_dir)
            subprocess.call(["dcm2niix", "-o", nifti_dir, "-z", "y", "-f", r"%p_%s", scan_dir])
            if is_anat and args.deface:
                subprocess.call(["./deface.sh", nifti_dir])
                
            if is_derived(nifti_dir):
                bidsname = 'DERIVATIVES'

            # Compressing folder and sending it to XNAT
            subprocess.call(["./send_nii.sh", nifti_dir, args.host])

        # Remove DICOMs when NIFTIs were saved
        if args.save_nifti and args.remove_dicoms:
            sess.delete('/data/archive/experiments/{}/scans/{}/resources/{}'.format(args.session, scan.id, dcm_dir))
        
        # Renaming, if necessary
        if args.rename_types and bidsname and scan.type != bidsname:
            print('renaming...')
            scan.type = bidsname

        subprocess.call(['rm', '-rf', '/tmp/*'])

# init
if __name__ == '__main__':
    main()


