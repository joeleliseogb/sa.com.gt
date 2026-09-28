<?php
$config = [];
$config['db_dsnw'] = 'sqlite:///C:/SimplyGest/ResumenEjecutivo/web/roundcube/roundcube.db';
$config['default_host'] = 'localhost';
$config['imap_host'] = 'localhost:143';
$config['smtp_host'] = 'localhost:25';
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';
$config['support_url'] = 'https://wa.me/50245550004';
$config['product_name'] = 'Correo Corporativo CDPE & Asociados | sa.com.gt';
$config['des_key'] = 'CdPeSaGt2026Secure24Key';
$config['plugins'] = [
    'archive',
    'zipdownload',
];
$config['language'] = 'es_ES';
$config['skin'] = 'elastic';
$config['enable_installer'] = false;
$config['create_default_folders'] = true;
$config['default_folders'] = ['INBOX', 'Drafts', 'Sent', 'Junk', 'Trash'];
$config['log_driver'] = 'file';
$config['log_dir'] = 'C:/SimplyGest/ResumenEjecutivo/web/roundcube/logs';
$config['temp_dir'] = 'C:/SimplyGest/ResumenEjecutivo/web/roundcube/temp';
?>
