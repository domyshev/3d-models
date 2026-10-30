import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { STLLoader } from 'three/addons/loaders/STLLoader.js';

const $ = (id) => document.getElementById(id);
const formatSize = (size) => size < 1024 * 1024 ? `${(size / 1024).toFixed(0)} KB` : `${(size / 1024 / 1024).toFixed(1)} MB`;
const formatDate = (date) => new Date(date * 1000).toLocaleString('en-GB', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
const cube = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.3" aria-hidden="true"><path d="m12 2 9 5v10l-9 5-9-5V7zM3 7l9 5 9-5M12 12v10M7.5 4.5l9 5"/></svg>';
let models = [], selected = null, selectedVersion = null, mesh = null, grid = null;
let loadSerial = 0, activeRequest = null, renderer = null, controls = null, camera = null;
let radius = 100;
const scene = new THREE.Scene();
scene.background = null;
scene.up.set(0, 0, 1);
const viewport = $('viewport');
const darkTheme = () => document.documentElement.dataset.theme === 'dark';
const modelColor = () => darkTheme() ? 0xc58a9e : 0x975569;

function applySceneTheme() {
  if (mesh) mesh.material.color.setHex(modelColor());
  if (grid) {
    const positions = grid.geometry.attributes.position;
    const colors = grid.geometry.attributes.color;
    const major = new THREE.Color(darkTheme() ? 0x80606e : 0xbb9ba7);
    const minor = new THREE.Color(darkTheme() ? 0x59404c : 0xd7c3c9);
    for (let i = 0; i < positions.count; i += 2) {
      const center = positions.getX(i) === positions.getX(i + 1) ? positions.getX(i) === 0 : positions.getZ(i) === 0;
      const color = center ? major : minor;
      colors.setXYZ(i, color.r, color.g, color.b);
      colors.setXYZ(i + 1, color.r, color.g, color.b);
    }
    colors.needsUpdate = true;
    grid.material.opacity = darkTheme() ? 0.5 : 0.65;
  }
}
window.addEventListener('themechange', applySceneTheme);

function initializeScene() {
  renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.outputColorSpace = THREE.SRGBColorSpace;
  renderer.setClearColor(0x000000, 0);
  viewport.prepend(renderer.domElement);
  renderer.domElement.setAttribute('aria-label', 'Interactive 3D model. Drag to orbit and scroll to zoom.');
  camera = new THREE.PerspectiveCamera(38, 1, 0.1, 10000);
  camera.up.set(0, 0, 1);
  controls = new OrbitControls(camera, renderer.domElement);
  controls.enableDamping = true;
  controls.dampingFactor = 0.08;
  controls.autoRotateSpeed = 1;
  scene.add(new THREE.HemisphereLight(0xfff8fa, 0x78636c, 2.3));
  const key = new THREE.DirectionalLight(0xffffff, 3.2);
  key.position.set(-150, -100, 260);
  scene.add(key);
  const rim = new THREE.DirectionalLight(0xf1cad7, 1.3);
  rim.position.set(180, 100, 100);
  scene.add(rim);
  new ResizeObserver(() => {
    const width = viewport.clientWidth, height = viewport.clientHeight;
    if (!width || !height) return;
    renderer.setSize(width, height);
    camera.aspect = width / height;
    camera.updateProjectionMatrix();
  }).observe(viewport);
  renderer.setAnimationLoop(() => {
    controls.update();
    renderer.render(scene, camera);
  });
}

function resetView() {
  if (!camera) return;
  const aspectScale = Math.max(1, 1 / camera.aspect);
  const distance = radius / Math.sin(THREE.MathUtils.degToRad(camera.fov / 2)) * 1.15 * aspectScale;
  camera.position.set(0.72, -0.95, 0.68).normalize().multiplyScalar(distance);
  camera.near = Math.max(radius / 1000, 0.001);
  camera.far = distance * 40;
  camera.updateProjectionMatrix();
  controls.target.set(0, 0, 0);
  controls.minDistance = radius * 0.1;
  controls.maxDistance = distance * 8;
  controls.update();
}

function renderList() {
  const term = $('search').value.trim().toLocaleLowerCase();
  const filtered = models.filter((model) => model.id.toLocaleLowerCase().replaceAll('_', ' ').includes(term.replaceAll('_', ' ')));
  const sort = $('sort').value;
  filtered.sort(sort === 'name' ? (a, b) => a.name.localeCompare(b.name) : sort === 'oldest' ? (a, b) => a.modified - b.modified || a.id.localeCompare(b.id) : (a, b) => b.modified - a.modified || a.id.localeCompare(b.id));
  $('count').textContent = term ? `${filtered.length} / ${models.length}` : models.length;
  const list = $('model-list');
  list.replaceChildren();
  if (!filtered.length) {
    const empty = document.createElement('p');
    empty.className = 'empty';
    empty.textContent = term ? 'No matches. Try another name.' : 'The collection is empty. New STL files will appear automatically.';
    list.append(empty);
  }
  for (const model of filtered) {
    const button = document.createElement('button');
    button.className = `model-card${selected?.id === model.id ? ' active' : ''}`;
    button.setAttribute('aria-pressed', String(selected?.id === model.id));
    const icon = document.createElement('span');
    icon.className = 'model-icon';
    icon.innerHTML = cube;
    const body = document.createElement('span');
    body.className = 'card-body';
    const name = document.createElement('span');
    name.className = 'card-name';
    name.textContent = model.name.replace(/\.stl$/i, '').replace(/^\d{4}-\d{2}-\d{2}_/, '').replaceAll('_', ' ');
    const meta = document.createElement('span');
    meta.className = 'card-meta';
    meta.textContent = `${new Date(model.modified * 1000).toLocaleDateString('en-GB')} · ${formatSize(model.size)}`;
    body.append(name, meta);
    button.append(icon, body);
    button.title = model.id;
    button.onclick = () => selectModel(model);
    list.append(button);
  }
}

async function selectModel(model) {
  selected = model;
  selectedVersion = model.version;
  const serial = ++loadSerial;
  activeRequest?.abort();
  activeRequest = new AbortController();
  renderList();
  const hash = new URLSearchParams({ model: model.id });
  history.replaceState(null, '', `#${hash}`);
  $('model-title').textContent = model.name.replace(/\.stl$/i, '').replace(/^\d{4}-\d{2}-\d{2}_/, '').replaceAll('_', ' ');
  $('folder').textContent = model.folder === '.' ? 'COLLECTION / STL' : model.folder;
  $('model-subtitle').textContent = `${formatDate(model.modified)} · ${model.name}`;
  $('download').href = model.url;
  $('download').download = model.name;
  $('download').classList.remove('disabled');
  $('download').setAttribute('aria-disabled', 'false');
  $('file-size').textContent = formatSize(model.size);
  $('dimensions').textContent = '—';
  $('triangles').textContent = '—';
  $('status').textContent = renderer ? 'Loading model…' : '3D is unavailable in this browser. You can still download the STL.';
  if (!renderer) return;
  if (mesh) { scene.remove(mesh); mesh.geometry.dispose(); mesh.material.dispose(); mesh = null; }
  try {
    const response = await fetch(`${model.url}?v=${encodeURIComponent(model.version)}`, { signal: activeRequest.signal });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const buffer = await response.arrayBuffer();
    if (serial !== loadSerial) return;
    const geometry = new STLLoader().parse(buffer);
    geometry.computeBoundingBox();
    const size = geometry.boundingBox.getSize(new THREE.Vector3());
    if (!geometry.attributes.position.count || ![size.x, size.y, size.z].every(Number.isFinite) || size.length() === 0) {
      geometry.dispose();
      throw new Error('Invalid geometry');
    }
    geometry.center();
    geometry.computeVertexNormals();
    geometry.computeBoundingSphere();
    radius = Math.max(geometry.boundingSphere.radius, 0.1);
    mesh = new THREE.Mesh(geometry, new THREE.MeshStandardMaterial({ color: modelColor(), roughness: 0.6, metalness: 0.12, side: THREE.DoubleSide, wireframe: $('wireframe').getAttribute('aria-pressed') === 'true' }));
    scene.add(mesh);
    if (grid) { scene.remove(grid); grid.geometry.dispose(); grid.material.dispose(); }
    const gridSize = Math.pow(10, Math.ceil(Math.log10(radius * 3)));
    grid = new THREE.GridHelper(gridSize, 20, 0x53654f, 0x344138);
    grid.rotation.x = Math.PI / 2;
    grid.position.z = -size.z / 2 - radius * 0.003;
    grid.material.transparent = true;
    grid.material.opacity = 0.42;
    scene.add(grid);
    applySceneTheme();
    $('dimensions').textContent = [size.x, size.y, size.z].map((n) => n.toFixed(1)).join(' × ');
    $('triangles').textContent = (geometry.attributes.position.count / 3).toLocaleString('en-GB');
    $('status').textContent = '';
    resetView();
  } catch (error) {
    if (serial === loadSerial && error.name !== 'AbortError') $('status').textContent = 'Could not open the model. Refresh the list or download the STL.';
  }
}

let refreshing = false;
async function refresh() {
  if (refreshing) return;
  refreshing = true;
  try {
    const response = await fetch('/api/models', { cache: 'no-cache' });
    if (!response.ok) throw new Error('Catalog unavailable');
    const data = await response.json();
    models = data.models;
    $('connection').textContent = 'Collection updated';
    $('connection').classList.remove('error');
    renderList();
    const requested = new URLSearchParams(location.hash.slice(1)).get('model');
    const current = selected && models.find((m) => m.id === selected.id);
    if (!selected && models.length) await selectModel(models.find((m) => m.id === requested) || models[0]);
    else if (current && current.version !== selectedVersion) await selectModel(current);
    else if (!models.length) $('status').textContent = 'Your STL models will appear here';
  } catch {
    $('connection').textContent = 'Disconnected · retrying automatically';
    $('connection').classList.add('error');
    if (!selected) $('status').textContent = 'Could not load the collection. Reconnecting…';
  } finally { refreshing = false; }
}

try { initializeScene(); } catch { $('status').textContent = '3D is unavailable in this browser. You can still download the STL.'; }
$('search').addEventListener('input', renderList);
$('sort').addEventListener('change', renderList);
$('refresh').addEventListener('click', refresh);
$('reset').addEventListener('click', resetView);
$('wireframe').addEventListener('click', () => {
  const enabled = $('wireframe').getAttribute('aria-pressed') !== 'true';
  $('wireframe').setAttribute('aria-pressed', String(enabled));
  if (mesh) mesh.material.wireframe = enabled;
});
$('rotate').addEventListener('click', () => {
  const enabled = $('rotate').getAttribute('aria-pressed') !== 'true';
  $('rotate').setAttribute('aria-pressed', String(enabled));
  if (controls) controls.autoRotate = enabled;
});
window.addEventListener('hashchange', () => {
  const id = new URLSearchParams(location.hash.slice(1)).get('model');
  const model = models.find((m) => m.id === id);
  if (model && model.id !== selected?.id) selectModel(model);
});
refresh();
setInterval(() => { if (!document.hidden) refresh(); }, 15000);
document.addEventListener('visibilitychange', () => { if (!document.hidden) refresh(); });
