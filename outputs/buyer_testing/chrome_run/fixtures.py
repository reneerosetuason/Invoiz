from pathlib import Path
import datetime as dt
import json
import subprocess
import sys
import uuid
import pymysql

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
STATE = HERE / 'fixture_state.json'


def settings():
    env = {}
    for line in (ROOT / 'backend/.env').read_text(encoding='utf-8').splitlines():
        if '=' in line and not line.lstrip().startswith('#'):
            key, value = line.split('=', 1)
            env[key.strip()] = value.strip().strip('"').strip("'")
    return env


def connect(database=None):
    env = settings()
    return pymysql.connect(host=env.get('DB_HOST', '127.0.0.1'), port=int(env.get('DB_PORT', 3306)),
        user=env.get('DB_USERNAME', 'root'), password=env.get('DB_PASSWORD', ''),
        database=database or env['DB_DATABASE'], charset='utf8mb4', autocommit=True)


def test_connection():
    state = json.loads(STATE.read_text())
    assert state['isolation'] == 'dedicated fictional records'
    name = state['database']
    return connect(name)


def setup():
    if STATE.exists():
        print(STATE.read_text())
        return
    source = settings()['DB_DATABASE']
    run_id = uuid.uuid4().hex[:8]
    target = source
    db = connect()
    with db.cursor() as cur:
        created = {}
        def insert(table, values):
            cols = ','.join('`' + c + '`' for c in values)
            cur.execute('INSERT INTO `' + table + '` (' + cols + ') VALUES (' + ','.join(['%s']*len(values)) + ')', tuple(values.values()))
            created.setdefault(table, []).append(cur.lastrowid)
            return cur.lastrowid

        def hashed(password):
            result = subprocess.run(['C:/php/php.exe', '-r', 'echo password_hash($argv[1], PASSWORD_BCRYPT);', password], capture_output=True, text=True, check=True)
            return result.stdout.strip()

        ids = {'users': {}, 'products': {}, 'variants': {}, 'addresses': {}, 'vouchers': {}, 'categories': {}}
        accounts = [
            ('buyer1', 'Juan Miguel', 'Dela Cruz', 'juanmiguel.delacruz@example.com', 'Mamimili@2026', 'buyer', '09171234567'),
            ('buyer2', 'Ana Marie', 'Reyes', 'anamarie.reyes@example.com', 'Suki#2026Ana', 'buyer', '09173456789'),
            ('seller1', 'Maria Clara', 'Santos', 'mariaclara.santos@example.com', 'Tindahan@2026', 'seller', '09170000011'),
            ('seller2', 'Roberto', 'Villanueva', 'roberto.villanueva@example.com', 'Gadget#Hub26', 'seller', '09170000012'),
        ]
        for key, first, last, email, password, role, phone in accounts:
            email = email.replace('@', '+' + run_id + '@')
            ids['users'][key] = insert('users', {'first_name': first, 'last_name': last, 'email': email, 'password': hashed(password), 'phone': phone,
                'sex': 'other', 'birthday': '1998-05-14', 'age': 28, 'role': role, 'approval_status': 'approved', 'status': 'active',
                'email_verified_at': '2026-10-23 08:00:00'})
        for key, name, line in [('seller1','Maria Clara Handicrafts','Home & Living'),('seller2','RV Gadget Hub','Electronics')]:
            insert('sellers', {'user_id': ids['users'][key], 'business_name': name, 'line_of_business': line, 'approval_status': 'approved', 'status': 'active'})
        for name in ["Women's Bags",'Home & Living','Electronics']:
            cur.execute('SELECT id FROM categories WHERE name=%s',(name,))
            found = cur.fetchone()
            ids['categories'][name] = found[0] if found else insert('categories', {'name': name, 'status': 'active'})
        products = [
            ('P-01','seller1','Abaca Woven Tote Bag',199,36,"Women's Bags",'0.4 kg'),
            ('P-02','seller1','Rattan Fruit Basket',450,20,'Home & Living','0.8 kg'),
            ('P-03','seller1','Capiz Shell Lamp',1250,1,'Home & Living','1.5 kg'),
            ('P-04','seller1','Banig Placemat Set of 4',350,0,'Home & Living','0.5 kg'),
            ('P-05','seller2','USB-C Fast Charger 20W',399,50,'Electronics','0.2 kg'),
            ('P-06','seller2','Wireless Earbuds X2',1499,20,'Electronics','0.3 kg'),
            ('P-07','seller2','Power Bank 10000mAh',899,5,'Electronics','0.4 kg'),
        ]
        for ref, seller, name, price, stock, category, weight in products:
            ids['products'][ref] = insert('products', {'seller_id': ids['users'][seller], 'category_id': ids['categories'][category],
                'name': name, 'description': name + ' prepared as a fictional workbook test item.', 'price': price, 'stock': stock,
                'status': 'active', 'weight': weight, 'rating': 4.5, 'sku': ref})
        for label, price, stock in [('Natural-S',199,10),('Natural-M',249,8),('Natural-L',299,5),('Black-S',199,10),('Black-M',249,0),('Black-L',299,3)]:
            ids['variants'][label] = insert('product_variants', {'product_id':ids['products']['P-01'],'variant_type':'Color / Size',
                'variant_value':label,'price_adjustment':price-199,'price':price,'stock':stock,'status':'active','sku':'MCH-TOTE-'+label})
        for label in ['Black','White']:
            ids['variants']['Earbuds-'+label] = insert('product_variants', {'product_id':ids['products']['P-06'],'variant_type':'Color',
                'variant_value':label,'price_adjustment':0,'price':1499,'stock':10,'status':'active'})
        addresses = [
            ('ADDR-1','buyer1','Juan Miguel Dela Cruz','09171234567','45 Kalayaan Ave.','Central','Quezon City','Metro Manila','1100',1),
            ('ADDR-3','buyer2','Ana Marie Reyes','09173456789','78 Osmeña Blvd.','Capitol Site','Cebu City','Cebu','6000',1),
        ]
        for ref, owner, recipient, phone, street, barangay, city, province, postal, default in addresses:
            ids['addresses'][ref] = insert('addresses',{'buyer_id':ids['users'][owner],'recipient_name':recipient,'phone':phone,
                'address_line':street,'barangay':barangay,'city':city,'province':province,'postal_code':postal,'is_default':default})
        today = dt.date(2026,10,23)
        vouchers = [('MCH50','fixed',50,300,None,100,0,-1,30),('MCH10','percent',10,500,100,50,0,-1,30),
            ('RVSECRET','fixed',100,1000,None,20,0,-1,30),('MCHOLD','fixed',30,200,None,100,0,-30,-1),
            ('MCHSOON','fixed',30,200,None,100,0,1,30),('MCHMAX','fixed',20,100,None,1,1,-1,30),
            ('PLAT100','fixed',100,1000,None,100,0,-1,30),('FREESHIP','free_shipping',50,300,50,100,0,-1,30),
            ('MCHT100','fixed',100,100,None,100,0,-1,30)]
        for code, kind, val, minimum, cap, limit, used, start, end in vouchers:
            ids['vouchers'][code] = insert('vouchers',{'code':code+'QA'+run_id,'name':code,'discount_type':kind,'discount_value':val,
                'min_spend':minimum,'max_discount':cap,'usage_limit':limit,'used_count':used,'status':'active',
                'valid_from':today+dt.timedelta(days=start),'valid_until':today+dt.timedelta(days=end)})
        for buyer in ['buyer1','buyer2']:
            insert('carts',{'buyer_id':ids['users'][buyer]})
    db.close()
    state = {'database':target,'isolation':'dedicated fictional records','run_id':run_id,'created_ids':created,'ids':ids,'fixture_limitations':['No seller/logistics app was run.',
        'Combined color/size options were stored in the variant fields supported by the buyer app.','Existing accounts, orders and products were not edited.',
        'Test account emails and voucher codes have a unique suffix to avoid touching existing records.']}
    STATE.write_text(json.dumps(state,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps({'database':target,'isolation':'dedicated fictional records','fictional_buyers':2,'fictional_products':7}))


if __name__ == '__main__':
    setup()
