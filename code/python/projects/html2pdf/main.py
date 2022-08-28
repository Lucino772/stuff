import pdfkit
import random
from jinja2 import Environment, PackageLoader, select_autoescape

def get_totals(items: list, vat: float):
    sub = sum([item['total_price'] for item in items])

    return  {
        'sub_total': sub,
        'vat_amount': sub * vat,
        'total': sub * (1 + vat)
    }

def get_items(n: int):
    for i in range(n):
        qty = random.randint(1, 3)
        yield {
            'description': 'Item #{}'.format(i),
            'quantity': qty,
            'unit_price': 100,
            'total_price': qty * 100
        }

env = Environment(
    loader=PackageLoader("invoice_gen"),
    autoescape=select_autoescape()
)

template = env.get_template("index.html")

items = list(get_items(20))

data = {
    # Company
    'company_name': 'A Company Inc.',
    'company_address': 'Somewhere Over The Rainbow',
    'company_phone': 'A phone number',
    'company_email': 'example@example.com',
    # Invoice
    'invoice_no': '001',
    'invoice_date': '14/08/2022',
    'invoice_due_date': '14/09/2022',
    # Client
    'client_name': 'A Company Inc.',
    'client_address': 'Somewhere Over The Rainbow',
    'client_phone': 'A phone number',
    'client_email': 'example@example.com',
    # Bank Details
    'bank_account_no': 'xxxxxxxxxx',
    'bank_bic': 'xxxxxxxxxx',
    'bank_iban': 'xxxxxxxxxxxxxxxxxxx',
    # Items
    'items': items,
    'totals': get_totals(items, 0.21)
}

options = {
    # 'margin-bottom': '0',
    # 'margin-left': '0',
    # 'margin-right': '0',
    # 'margin-top': '0',
    'enable-local-file-access': None,
    'print-media-type': None
}

filename = 'result.html'
with open(filename, 'w') as fp:
    fp.write(template.render(**data))

pdfkit.from_file(filename, 'index.pdf', options=options)