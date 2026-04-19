/**
 * ShopEase – Frontend JavaScript
 * E-Commerce DBMS Academic Project
 * All data is stored in localStorage (simulates DB queries from backend)
 */

'use strict';

// ============================================================
// PRODUCT DATA  (mirrors 02_insert_data.sql)
// ============================================================
const PRODUCTS = [
  { id:1,  catName:'Mobiles',           name:'Samsung Galaxy A54',      brand:'Samsung',        price:28999, originalPrice:34999, stock:150, rating:5.0, reviews:1,   emoji:'📱', desc:'5G smartphone with 50MP camera and stunning AMOLED display.' },
  { id:2,  catName:'Mobiles',           name:'Redmi Note 13 Pro',       brand:'Redmi',          price:22999, originalPrice:27999, stock:200, rating:4.2, reviews:0,   emoji:'📱', desc:'200MP camera, AMOLED display, 5000mAh battery.' },
  { id:3,  catName:'Laptops',           name:'HP Pavilion 15',          brand:'HP',             price:62990, originalPrice:74990, stock:80,  rating:4.0, reviews:1,   emoji:'💻', desc:'Intel i5 12th Gen, 16GB RAM, 512GB SSD laptop.' },
  { id:4,  catName:'Laptops',           name:'Lenovo IdeaPad 5',        brand:'Lenovo',         price:54999, originalPrice:64999, stock:60,  rating:4.5, reviews:0,   emoji:'💻', desc:'AMD Ryzen 5, 8GB RAM, 256GB SSD, FHD Display.' },
  { id:5,  catName:"Men's Clothing",    name:'Peter England Formal Shirt',brand:'Peter England',price:1299,  originalPrice:2499,  stock:300, rating:4.0, reviews:1,   emoji:'👔', desc:'100% cotton slim fit formal shirt. Available in multiple colours.' },
  { id:6,  catName:"Women's Clothing",  name:'Biba Ethnic Kurta',       brand:'Biba',           price:1799,  originalPrice:2999,  stock:250, rating:3.8, reviews:0,   emoji:'👗', desc:'Cotton printed ethnic kurta for women. Comfortable and stylish.' },
  { id:7,  catName:'Kitchen Appliances',name:'Prestige Induction Cooktop',brand:'Prestige',     price:3999,  originalPrice:5499,  stock:120, rating:3.0, reviews:1,   emoji:'🍳', desc:'2000W induction cooktop with 8 preset menus and auto-off safety.' },
  { id:8,  catName:'Books',             name:'Let Us C – Yashavant Kanetkar',brand:'BPB Publications',price:499,originalPrice:899,stock:500,rating:5.0,reviews:1,    emoji:'📚', desc:'Best-selling C programming book used in universities across India.' },
  { id:9,  catName:'Sports & Fitness',  name:'Cosco Football',          brand:'Cosco',          price:899,   originalPrice:1199,  stock:180, rating:4.1, reviews:0,   emoji:'⚽', desc:'Size 5 PU leather football. Suitable for official match play.' },
  { id:10, catName:'Mobiles',           name:'boAt Airdopes 141',       brand:'boAt',           price:1299,  originalPrice:2499,  stock:400, rating:4.3, reviews:0,   emoji:'🎧', desc:'Bluetooth 5.1 TWS earbuds with 42-hour total playtime.' },
];

// ============================================================
// STORAGE HELPERS  (simulate DB persistence)
// ============================================================
const getCart  = ()  => JSON.parse(localStorage.getItem('se_cart')  || '[]');
const saveCart = (c) => localStorage.setItem('se_cart', JSON.stringify(c));
const getUser  = ()  => JSON.parse(localStorage.getItem('se_user')  || 'null');
const saveUser = (u) => localStorage.setItem('se_user', JSON.stringify(u));
const getOrders= ()  => JSON.parse(localStorage.getItem('se_orders')|| '[]');
const saveOrders=(o) => localStorage.setItem('se_orders', JSON.stringify(o));

// ============================================================
// TOAST
// ============================================================
function showToast(msg, duration = 3000) {
  const t = document.getElementById('toast');
  if (!t) return;
  t.textContent = msg;
  t.classList.add('show');
  setTimeout(() => t.classList.remove('show'), duration);
}

// ============================================================
// CART BADGE UPDATE
// ============================================================
function updateCartBadge() {
  const badge = document.getElementById('cartCount');
  if (!badge) return;
  const cart = getCart();
  const total = cart.reduce((s, i) => s + i.qty, 0);
  badge.textContent = total;
}

// ============================================================
// PAGE DETECTION
// ============================================================
const page = (() => {
  const p = location.pathname.split('/').pop() || 'index.html';
  if (p === 'login.html')  return 'login';
  if (p === 'cart.html')   return 'cart';
  if (p === 'order.html')  return 'order';
  return 'home';
})();


// ============================================================
// ──────────────── HOME PAGE ────────────────
// ============================================================
if (page === 'home') {

  let activeCategory = 'all';
  let sortMode = 'default';
  let searchTerm = '';

  // ── Render products ──
  function renderProducts() {
    const grid = document.getElementById('productGrid');
    if (!grid) return;

    let list = [...PRODUCTS];

    // filter by category
    if (activeCategory !== 'all')
      list = list.filter(p => p.catName === activeCategory);

    // filter by search
    if (searchTerm)
      list = list.filter(p =>
        p.name.toLowerCase().includes(searchTerm) ||
        p.brand.toLowerCase().includes(searchTerm) ||
        p.catName.toLowerCase().includes(searchTerm)
      );

    // sort
    if      (sortMode === 'price-asc')  list.sort((a,b) => a.price - b.price);
    else if (sortMode === 'price-desc') list.sort((a,b) => b.price - a.price);
    else if (sortMode === 'rating')     list.sort((a,b) => b.rating - a.rating);
    else if (sortMode === 'name')       list.sort((a,b) => a.name.localeCompare(b.name));

    if (list.length === 0) {
      grid.innerHTML = `<div style="grid-column:1/-1;text-align:center;padding:60px;color:var(--text-muted);">
        <div style="font-size:3rem">🔎</div>
        <p style="margin-top:12px">No products found</p>
      </div>`;
      return;
    }

    grid.innerHTML = list.map(p => {
      const disc = Math.round((1 - p.price / p.originalPrice) * 100);
      const stars = '★'.repeat(Math.round(p.rating)) + '☆'.repeat(5 - Math.round(p.rating));
      const stockCls = p.stock === 0 ? 'out' : p.stock < 50 ? 'low' : '';
      const stockTxt = p.stock === 0 ? 'Out of Stock' : p.stock < 50 ? `Only ${p.stock} left!` : 'In Stock';

      return `
      <article class="product-card" data-id="${p.id}" id="card-${p.id}">
        <div class="card-img">
          <span aria-hidden="true">${p.emoji}</span>
          <span class="card-badge">${disc}% OFF</span>
          <button class="card-wishlist" data-id="${p.id}" aria-label="Wishlist">🤍</button>
        </div>
        <div class="card-body">
          <span class="card-brand">${p.brand}</span>
          <h3 class="card-name">${p.name}</h3>
          <div class="card-rating">
            <span class="stars">${stars}</span>
            <span class="rating-count">(${p.reviews} review${p.reviews !== 1 ? 's' : ''})</span>
          </div>
          <div class="card-price">
            ₹${p.price.toLocaleString('en-IN')}
            <span class="original">₹${p.originalPrice.toLocaleString('en-IN')}</span>
            <span class="discount">${disc}% off</span>
          </div>
          <span class="stock-tag ${stockCls}">${stockTxt}</span>
          <div class="card-actions">
            <button class="btn btn-outline quick-cart" data-id="${p.id}">🛒 Add</button>
            <button class="btn btn-primary quick-view" data-id="${p.id}">View</button>
          </div>
        </div>
      </article>`;
    }).join('');

    // Attach events
    grid.querySelectorAll('.quick-view').forEach(btn =>
      btn.addEventListener('click', e => { e.stopPropagation(); openModal(+btn.dataset.id); })
    );
    grid.querySelectorAll('.quick-cart').forEach(btn =>
      btn.addEventListener('click', e => { e.stopPropagation(); addToCart(+btn.dataset.id, 1); })
    );
    grid.querySelectorAll('.product-card').forEach(card =>
      card.addEventListener('click', () => openModal(+card.dataset.id))
    );
    grid.querySelectorAll('.card-wishlist').forEach(btn =>
      btn.addEventListener('click', e => {
        e.stopPropagation();
        btn.textContent = btn.textContent === '🤍' ? '❤️' : '🤍';
        showToast(btn.textContent === '❤️' ? '❤️ Added to wishlist' : 'Removed from wishlist');
      })
    );
  }

  // ── Category Pills ──
  document.getElementById('categoryPills')?.addEventListener('click', e => {
    const pill = e.target.closest('.pill');
    if (!pill) return;
    document.querySelectorAll('.pill').forEach(p => p.classList.remove('active'));
    pill.classList.add('active');
    activeCategory = pill.dataset.cat;
    renderProducts();
  });

  // ── Sort ──
  document.getElementById('sortSelect')?.addEventListener('change', e => {
    sortMode = e.target.value;
    renderProducts();
  });

  // ── Search ──
  document.getElementById('searchBtn')?.addEventListener('click', () => {
    searchTerm = document.getElementById('searchInput').value.trim().toLowerCase();
    renderProducts();
  });
  document.getElementById('searchInput')?.addEventListener('keyup', e => {
    if (e.key === 'Enter') {
      searchTerm = e.target.value.trim().toLowerCase();
      renderProducts();
    }
  });

  // ── MODAL ──
  function openModal(id) {
    const p = PRODUCTS.find(x => x.id === id);
    if (!p) return;
    const disc = Math.round((1 - p.price / p.originalPrice) * 100);
    const stars = '★'.repeat(Math.round(p.rating)) + '☆'.repeat(5 - Math.round(p.rating));

    document.getElementById('modalEmoji').textContent   = p.emoji;
    document.getElementById('modalBadge').textContent   = p.catName;
    document.getElementById('modalName').textContent    = p.name;
    document.getElementById('modalBrand').textContent   = p.brand;
    document.getElementById('modalDesc').textContent    = p.desc;
    document.getElementById('modalPrice').textContent   = `₹${p.price.toLocaleString('en-IN')}`;
    document.getElementById('modalRating').textContent  = `${stars} (${p.rating})`;
    document.getElementById('modalQty').value = 1;
    document.getElementById('modalQty').max   = Math.min(p.stock, 10);

    const addBtn = document.getElementById('modalAddCart');
    addBtn.dataset.id = id;

    document.getElementById('modalOverlay').classList.add('open');
  }

  document.getElementById('modalClose')?.addEventListener('click', () =>
    document.getElementById('modalOverlay').classList.remove('open')
  );
  document.getElementById('modalOverlay')?.addEventListener('click', e => {
    if (e.target === document.getElementById('modalOverlay'))
      document.getElementById('modalOverlay').classList.remove('open');
  });

  document.getElementById('modalAddCart')?.addEventListener('click', e => {
    const id  = +e.currentTarget.dataset.id;
    const qty = +document.getElementById('modalQty').value;
    addToCart(id, qty);
    document.getElementById('modalOverlay').classList.remove('open');
  });

  // Init
  renderProducts();
}


// ============================================================
// ──────────────── LOGIN PAGE ────────────────
// ============================================================
if (page === 'login') {

  // Tab switcher
  document.querySelectorAll('.auth-tab').forEach(tab => {
    tab.addEventListener('click', () => {
      document.querySelectorAll('.auth-tab').forEach(t => {
        t.classList.remove('active');
        t.setAttribute('aria-selected','false');
      });
      tab.classList.add('active');
      tab.setAttribute('aria-selected','true');
      document.querySelectorAll('.auth-form').forEach(f => f.classList.add('hidden'));
      document.getElementById(tab.dataset.target).classList.remove('hidden');
    });
  });

  // Password toggle
  document.querySelectorAll('.toggle-pw').forEach(btn => {
    btn.addEventListener('click', () => {
      const input = document.getElementById(btn.dataset.target);
      input.type = input.type === 'password' ? 'text' : 'password';
      btn.textContent = input.type === 'password' ? '👁' : '🙈';
    });
  });

  // Password strength
  const pwInput = document.getElementById('regPassword');
  if (pwInput) {
    pwInput.addEventListener('input', () => {
      const val = pwInput.value;
      const fill  = document.getElementById('pwFill');
      const label = document.getElementById('pwLabel');
      let score = 0;
      if (val.length >= 8) score++;
      if (/[A-Z]/.test(val)) score++;
      if (/[0-9]/.test(val)) score++;
      if (/[^A-Za-z0-9]/.test(val)) score++;

      const pcts  = ['0%','25%','50%','75%','100%'];
      const colors= ['','#ef4444','#f59e0b','#3b82f6','#10b981'];
      const labels= ['','Weak','Fair','Good','Strong'];

      fill.style.width      = pcts[score];
      fill.style.background = colors[score];
      label.textContent     = labels[score] || '';
    });
  }

  // LOGIN form
  document.getElementById('loginForm')?.addEventListener('submit', e => {
    e.preventDefault();
    const email = document.getElementById('loginEmail').value.trim();
    const pw    = document.getElementById('loginPassword').value;
    let valid = true;

    if (!email) { setErr('loginEmailErr','Email is required'); valid = false; }
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) { setErr('loginEmailErr','Invalid email'); valid = false; }
    else clearErr('loginEmailErr');

    if (!pw) { setErr('loginPwErr','Password is required'); valid = false; }
    else clearErr('loginPwErr');

    if (!valid) return;

    // Simulate auth (demo credentials)
    const VALID_USERS = [
      { email:'admin@ecommerce.com', password:'Admin@123', role:'admin',    name:'Admin User' },
      { email:'riya@gmail.com',      password:'Riya@123',  role:'customer', name:'Riya Sharma' },
      { email:'arjun@gmail.com',     password:'Arjun@123', role:'customer', name:'Arjun Patel' },
    ];
    const found = VALID_USERS.find(u => u.email === email && u.password === pw);
    if (!found) { setErr('loginPwErr','Invalid email or password'); return; }

    saveUser(found);
    showToast(`✅ Welcome back, ${found.name}!`);
    setTimeout(() => { location.href = 'index.html'; }, 1200);
  });

  // REGISTER form
  document.getElementById('registerForm')?.addEventListener('submit', e => {
    e.preventDefault();
    const name    = document.getElementById('regName').value.trim();
    const email   = document.getElementById('regEmail').value.trim();
    const phone   = document.getElementById('regPhone').value.trim();
    const pw      = document.getElementById('regPassword').value;
    const confirm = document.getElementById('regConfirm').value;
    const agree   = document.getElementById('agreeTerms').checked;
    let valid = true;

    if (!name)  { setErr('regNameErr','Name is required'); valid=false; } else clearErr('regNameErr');
    if (!email) { setErr('regEmailErr','Email is required'); valid=false; }
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) { setErr('regEmailErr','Invalid email'); valid=false; }
    else clearErr('regEmailErr');
    if (!phone || !/^[6-9][0-9]{9}$/.test(phone)) { setErr('regPhoneErr','Enter a valid 10-digit phone number'); valid=false; } else clearErr('regPhoneErr');
    if (pw.length < 8) { setErr('regPwErr','Min 8 characters required'); valid=false; } else clearErr('regPwErr');
    if (pw !== confirm) { setErr('regConfirmErr','Passwords do not match'); valid=false; } else clearErr('regConfirmErr');
    if (!agree) { setErr('agreeErr','Please accept terms'); valid=false; } else clearErr('agreeErr');

    if (!valid) return;

    saveUser({ email, name, phone, role:'customer' });
    showToast('🎉 Account created! Redirecting…');
    setTimeout(() => { location.href = 'index.html'; }, 1400);
  });

  function setErr(id, msg) {
    const el = document.getElementById(id);
    if (el) el.textContent = msg;
  }
  function clearErr(id) {
    const el = document.getElementById(id);
    if (el) el.textContent = '';
  }
}


// ============================================================
// ──────────────── CART PAGE ────────────────
// ============================================================
if (page === 'cart') {
  function renderCart() {
    const cart = getCart();
    const container = document.getElementById('cartItemsContainer');
    const emptyEl   = document.getElementById('emptyCart');
    const layoutEl  = document.getElementById('cartLayout');

    if (cart.length === 0) {
      emptyEl.classList.remove('hidden');
      layoutEl.classList.add('hidden');
      return;
    }
    emptyEl.classList.add('hidden');
    layoutEl.classList.remove('hidden');

    let subtotal = 0;

    container.innerHTML = cart.map(item => {
      const p = PRODUCTS.find(x => x.id === item.id);
      if (!p) return '';
      const lineTotal = p.price * item.qty;
      subtotal += lineTotal;

      return `
      <div class="cart-item" id="cart-item-${p.id}">
        <div class="cart-item-img">${p.emoji}</div>
        <div class="cart-item-info">
          <div class="cart-item-brand">${p.brand}</div>
          <div class="cart-item-name">${p.name}</div>
          <div class="cart-item-price">₹${lineTotal.toLocaleString('en-IN')}</div>
        </div>
        <div class="cart-item-actions">
          <div class="qty-control">
            <button class="qty-dec" data-id="${p.id}">−</button>
            <span>${item.qty}</span>
            <button class="qty-inc" data-id="${p.id}">+</button>
          </div>
          <button class="remove-btn" data-id="${p.id}" aria-label="Remove">🗑</button>
        </div>
      </div>`;
    }).join('');

    // Summary
    const disc       = Math.round(subtotal * 0.10);
    const grandTotal = subtotal - disc;
    const shipping   = grandTotal > 500 ? 'FREE' : '₹49';

    document.getElementById('subtotal').textContent  = `₹${subtotal.toLocaleString('en-IN')}`;
    document.getElementById('discount').textContent  = `-₹${disc.toLocaleString('en-IN')}`;
    document.getElementById('shipping').textContent  = shipping;
    document.getElementById('grandTotal').textContent = `₹${(grandTotal + (shipping === 'FREE' ? 0 : 49)).toLocaleString('en-IN')}`;

    // Events
    container.querySelectorAll('.qty-inc').forEach(btn =>
      btn.addEventListener('click', () => changeQty(+btn.dataset.id, 1))
    );
    container.querySelectorAll('.qty-dec').forEach(btn =>
      btn.addEventListener('click', () => changeQty(+btn.dataset.id, -1))
    );
    container.querySelectorAll('.remove-btn').forEach(btn =>
      btn.addEventListener('click', () => removeFromCart(+btn.dataset.id))
    );
  }

  function changeQty(id, delta) {
    const cart = getCart();
    const idx  = cart.findIndex(x => x.id === id);
    if (idx === -1) return;
    cart[idx].qty = Math.max(1, Math.min(10, cart[idx].qty + delta));
    saveCart(cart);
    renderCart();
    updateCartBadge();
  }

  function removeFromCart(id) {
    const cart = getCart().filter(x => x.id !== id);
    saveCart(cart);
    renderCart();
    updateCartBadge();
    showToast('Item removed from cart');
  }

  renderCart();
}


// ============================================================
// ──────────────── ORDER PAGE ────────────────
// ============================================================
if (page === 'order') {
  let currentStep = 1;
  let addressData = {};
  let paymentData = {};

  const steps = [null,
    document.getElementById('step1'),
    document.getElementById('step2'),
    document.getElementById('step3'),
    document.getElementById('successCard'),
  ];

  function goToStep(n) {
    steps.forEach((s, i) => { if (s) s.classList.toggle('hidden', i !== n); });
    document.querySelectorAll('.step').forEach(s => {
      const num = +s.dataset.step;
      s.classList.toggle('active', num === n);
      s.classList.toggle('done',   num <  n);
    });
    currentStep = n;
  }

  // Render sidebar
  function renderSidebar() {
    const cart = getCart();
    const sidebar = document.getElementById('sidebarItems');
    let total = 0;
    sidebar.innerHTML = cart.map(item => {
      const p = PRODUCTS.find(x => x.id === item.id);
      if (!p) return '';
      const line = p.price * item.qty;
      total += line;
      return `<div class="sidebar-item">
        <span class="item-name">${p.emoji} ${p.name} × ${item.qty}</span>
        <span>₹${line.toLocaleString('en-IN')}</span>
      </div>`;
    }).join('');
    document.getElementById('sidebarTotal').textContent = `₹${total.toLocaleString('en-IN')}`;
    return total;
  }
  renderSidebar();

  // Step 1: Address
  document.getElementById('addressForm')?.addEventListener('submit', e => {
    e.preventDefault();
    const name  = document.getElementById('fullName').value.trim();
    const phone = document.getElementById('addrPhone').value.trim();
    const addr  = document.getElementById('addressLine').value.trim();
    const pin   = document.getElementById('pincode').value.trim();
    let ok = true;

    [['fullName','fullNameErr',name,'Name required'],
     ['addrPhone','addrPhoneErr',phone,'Phone required'],
     ['addressLine','addrLineErr',addr,'Address required'],
    ].forEach(([,errId,val,msg]) => {
      const el = document.getElementById(errId);
      if (el) { if (!val) { el.textContent = msg; ok = false; } else el.textContent = ''; }
    });
    if (pin && !/^[0-9]{6}$/.test(pin)) {
      document.getElementById('pinErr').textContent = '6-digit PIN required';
      ok = false;
    } else { const el=document.getElementById('pinErr'); if(el) el.textContent=''; }

    if (!ok) return;

    addressData = {
      name, phone,
      address: addr,
      city:    document.getElementById('city').value,
      state:   document.getElementById('state').value,
      pin,
    };
    goToStep(2);
  });

  // Step 2: Payment
  document.getElementById('payNextBtn')?.addEventListener('click', () => {
    const method = document.querySelector('input[name=payMethod]:checked')?.value;
    paymentData = { method };

    // Populate confirm
    document.getElementById('confirmAddrText').textContent =
      `${addressData.name}, ${addressData.address}, ${addressData.city}, ${addressData.state} – ${addressData.pin} | 📞 ${addressData.phone}`;
    document.getElementById('confirmPayText').textContent =
      method.replace(/_/g,' ').toUpperCase();

    const cart  = getCart();
    let   total = 0;
    const items = cart.map(item => {
      const p = PRODUCTS.find(x => x.id === item.id);
      if (!p) return '';
      total += p.price * item.qty;
      return `<div class="sidebar-item" style="padding:6px 0">
        <span>${p.emoji} ${p.name} × ${item.qty}</span>
        <span>₹${(p.price*item.qty).toLocaleString('en-IN')}</span>
      </div>`;
    }).join('');
    document.getElementById('confirmItems').innerHTML = items;
    document.getElementById('confirmTotal').textContent = `₹${total.toLocaleString('en-IN')}`;

    goToStep(3);
  });

  // Payment sub-forms
  document.querySelectorAll('input[name=payMethod]').forEach(radio => {
    radio.addEventListener('change', () => {
      document.getElementById('upiForm').classList.toggle('hidden', radio.value !== 'upi');
      document.getElementById('cardForm').classList.toggle('hidden', radio.value !== 'credit_card');
    });
  });

  document.getElementById('backToAddr')?.addEventListener('click', () => goToStep(1));

  // Step 3: Place order
  document.getElementById('placeOrderBtn')?.addEventListener('click', () => {
    const cart   = getCart();
    const orders = getOrders();
    const orderId= `ORD-${String(orders.length + 1).padStart(4,'0')}`;

    orders.push({
      orderId,
      items:   cart,
      address: addressData,
      payment: paymentData,
      date:    new Date().toISOString(),
      status:  'confirmed',
    });
    saveOrders(orders);
    saveCart([]);
    updateCartBadge();

    document.getElementById('orderIdDisplay').textContent = `#${orderId}`;
    goToStep(4);
    showToast('🎉 Order placed successfully!');
  });

  // UPI default visible, card hidden
  document.getElementById('upiForm')?.classList.remove('hidden');
  document.getElementById('cardForm')?.classList.add('hidden');
}


// ============================================================
// ADD TO CART (shared)
// ============================================================
function addToCart(id, qty = 1) {
  const cart = getCart();
  const idx  = cart.findIndex(x => x.id === id);
  const p    = PRODUCTS.find(x => x.id === id);
  if (!p || p.stock === 0) { showToast('❌ Product out of stock'); return; }

  if (idx > -1) {
    cart[idx].qty = Math.min(cart[idx].qty + qty, 10);
  } else {
    cart.push({ id, qty });
  }
  saveCart(cart);
  updateCartBadge();
  showToast(`🛒 ${p.name} added to cart!`);
}

// ============================================================
// INIT
// ============================================================
updateCartBadge();

// Update login link based on auth state
const user      = getUser();
const loginLink = document.getElementById('loginLink');
if (loginLink && user) {
  loginLink.textContent = `👤 ${user.name.split(' ')[0]}`;
  loginLink.href = '#';
  loginLink.addEventListener('click', e => {
    e.preventDefault();
    localStorage.removeItem('se_user');
    showToast('👋 Logged out');
    setTimeout(() => location.reload(), 800);
  });
}
