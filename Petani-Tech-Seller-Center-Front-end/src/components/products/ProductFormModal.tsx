import React, { useState } from 'react';
import {
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
  Image,
  Alert,
  ScrollView,
} from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { Modal } from '@/components/common/Modal';
import { Button } from '@/components/common/Button';
import { ProductCategory, CreateProductInput } from '@/types';
import { resolveProductImage } from '@/utils/productImage';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme/ThemeContext';
import {
  Upload,
  Camera,
  Check,
  Trash2,
} from 'lucide-react-native';

export interface ProductFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: CreateProductInput) => Promise<void>;
  initialData?: Partial<CreateProductInput>;
}

const CATEGORIES: ProductCategory[] = ['Pupuk', 'Pestisida', 'Benih', 'Alat Pertanian'];

const PRODUCT_ASSETS = [
  { label: 'Bionava', assetKey: 'asset:bionava' },
  { label: 'Cangkul', assetKey: 'asset:cangkul' },
  { label: 'Cangkul 2', assetKey: 'asset:cangkul2' },
  { label: 'Grao Verde', assetKey: 'asset:graoVerde' },
  { label: 'Pintinhos', assetKey: 'asset:pintinhos' },
  { label: 'Prosil', assetKey: 'asset:prosil' },
  { label: 'Pupuk NPK', assetKey: 'asset:pupukNpk' },
  { label: 'Skop', assetKey: 'asset:skop' },
  { label: 'Sprayer', assetKey: 'asset:sprayer' },
];

export const ProductFormModal: React.FC<ProductFormModalProps> = ({
  isOpen,
  onClose,
  onSubmit,
  initialData,
}) => {
  const { colors, isDark } = useTheme();

  const [name, setName] = useState(initialData?.name || '');
  const [category, setCategory] = useState<ProductCategory>(
    (initialData?.category as ProductCategory) || 'Pupuk'
  );
  const [price, setPrice] = useState(initialData?.price ? String(initialData.price) : '');
  const [stock, setStock] = useState(initialData?.stock ? String(initialData.stock) : '');
  const [unit, setUnit] = useState(initialData?.unit || 'Botol (1 Liter)');
  const [description, setDescription] = useState(initialData?.description || '');
  const [minStockAlert, setMinStockAlert] = useState(
    initialData?.minStockAlert ? String(initialData.minStockAlert) : '15'
  );
  const [imageUrl, setImageUrl] = useState(initialData?.image || 'asset:bionava');
  const [isLoading, setIsLoading] = useState(false);

  // Pick Image from Device Gallery
  const handlePickFromGallery = async () => {
    try {
      const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
      if (!permission.granted) {
        Alert.alert(
          'Izin Diperlukan',
          'Mohon izinkan akses galeri untuk mengunggah foto produk dari perangkat Anda.'
        );
        return;
      }

      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ['images'],
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.8,
      });

      if (!result.canceled && result.assets && result.assets.length > 0) {
        setImageUrl(result.assets[0].uri);
      }
    } catch {
      Alert.alert('Gagal Memilih Gambar', 'Terjadi kesalahan saat membuka galeri foto.');
    }
  };

  // Capture Image with Camera
  const handleCaptureCamera = async () => {
    try {
      const permission = await ImagePicker.requestCameraPermissionsAsync();
      if (!permission.granted) {
        Alert.alert(
          'Izin Diperlukan',
          'Mohon izinkan akses kamera untuk memotret produk langsung dari perangkat Anda.'
        );
        return;
      }

      const result = await ImagePicker.launchCameraAsync({
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.8,
      });

      if (!result.canceled && result.assets && result.assets.length > 0) {
        setImageUrl(result.assets[0].uri);
      }
    } catch {
      Alert.alert('Gagal Membuka Kamera', 'Terjadi kesalahan saat mengakses kamera perangkat.');
    }
  };

  const handleSubmit = async () => {
    if (!name.trim() || !price || !stock) {
      Alert.alert('Data Belum Lengkap', 'Nama produk, harga jual, dan jumlah stok wajib diisi.');
      return;
    }

    setIsLoading(true);
    try {
      await onSubmit({
        name: name.trim(),
        category,
        price: Number(price),
        stock: Number(stock),
        unit: unit.trim(),
        description: description.trim(),
        minStockAlert: Number(minStockAlert) || 10,
        image: imageUrl || undefined,
      });
      onClose();
    } finally {
      setIsLoading(false);
    }
  };

  const dynamicInputStyle = {
    backgroundColor: isDark ? 'rgba(22, 58, 38, 0.70)' : '#FFFFFF',
    borderColor: isDark ? 'rgba(209, 245, 232, 0.20)' : '#DDE8E0',
    color: isDark ? '#FFFFFF' : '#183326',
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title={initialData ? 'Ubah Informasi Produk' : 'Tambah Produk Pertanian'}
      description="Lengkapi detail produk pertanian untuk mulai menjual ke ribuan pembeli dan petani mitra."
    >
      <View style={styles.formContainer}>
        {/* Foto Produk Picker Section */}
        <View style={styles.fieldGroup}>
          <Text style={[styles.label, { color: isDark ? '#FFFFFF' : '#183326' }]}>
            Foto Produk Pertanian
          </Text>
          <View
            style={[
              styles.imagePickerCard,
              {
                backgroundColor: isDark ? 'rgba(22, 58, 38, 0.50)' : '#FAF9F6',
                borderColor: isDark ? 'rgba(209, 245, 232, 0.28)' : '#C6E2D0',
              },
            ]}
          >
            <View
              style={[
                styles.previewBox,
                {
                  backgroundColor: isDark ? 'rgba(255, 255, 255, 0.05)' : '#FFFFFF',
                  borderColor: isDark ? 'rgba(209, 245, 232, 0.18)' : '#DDE8E0',
                },
              ]}
            >
              <Image
                source={resolveProductImage(imageUrl, name)}
                style={styles.previewImage}
                resizeMode="cover"
              />
            </View>

            <View style={styles.imageControls}>
              <Text style={[styles.imagePickerHint, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                Pilih foto dari galeri perangkat atau pilih katalog aset:
              </Text>

              <View style={styles.deviceButtonRow}>
                <TouchableOpacity
                  onPress={handlePickFromGallery}
                  style={[
                    styles.devicePickerBtn,
                    {
                      backgroundColor: isDark ? 'rgba(64, 145, 108, 0.25)' : '#EAF4EE',
                      borderColor: isDark ? 'rgba(209, 245, 232, 0.30)' : '#C6E2D0',
                    },
                  ]}
                  activeOpacity={0.75}
                >
                  <Upload size={14} color={isDark ? '#D1F5E8' : '#31572C'} />
                  <Text style={[styles.devicePickerText, { color: isDark ? '#D1F5E8' : '#31572C' }]}>
                    Galeri Perangkat
                  </Text>
                </TouchableOpacity>

                <TouchableOpacity
                  onPress={handleCaptureCamera}
                  style={[
                    styles.devicePickerBtn,
                    {
                      backgroundColor: isDark ? 'rgba(64, 145, 108, 0.25)' : '#EAF4EE',
                      borderColor: isDark ? 'rgba(209, 245, 232, 0.30)' : '#C6E2D0',
                    },
                  ]}
                  activeOpacity={0.75}
                >
                  <Camera size={14} color={isDark ? '#D1F5E8' : '#31572C'} />
                  <Text style={[styles.devicePickerText, { color: isDark ? '#D1F5E8' : '#31572C' }]}>
                    Kamera
                  </Text>
                </TouchableOpacity>
              </View>

              {imageUrl ? (
                <TouchableOpacity
                  onPress={() => setImageUrl('')}
                  style={styles.removeRow}
                  activeOpacity={0.7}
                >
                  <Trash2 size={13} color="#EF4444" />
                  <Text style={styles.removeImageText}>Reset Foto</Text>
                </TouchableOpacity>
              ) : null}
            </View>
          </View>

          {/* Quick Assets Chips */}
          <View style={styles.assetChipsSection}>
            <Text style={[styles.subLabel, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
              Aset Gambar Produk Siap Pakai:
            </Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.assetChipsRow}>
              {PRODUCT_ASSETS.map((asset) => {
                const isSelected = imageUrl === asset.assetKey;
                return (
                  <TouchableOpacity
                    key={asset.assetKey}
                    onPress={() => {
                      setImageUrl(asset.assetKey);
                      if (!name) setName(asset.label);
                    }}
                    style={[
                      styles.assetChip,
                      {
                        backgroundColor: isSelected
                          ? isDark
                            ? 'rgba(64, 145, 108, 0.35)'
                            : '#D1F5E8'
                          : isDark
                          ? 'rgba(22, 58, 38, 0.60)'
                          : '#FFFFFF',
                        borderColor: isSelected
                          ? isDark
                            ? 'rgba(209, 245, 232, 0.45)'
                            : '#40916C'
                          : isDark
                          ? 'rgba(209, 245, 232, 0.18)'
                          : '#DDE8E0',
                      },
                    ]}
                    activeOpacity={0.75}
                  >
                    {isSelected && <Check size={12} color={isDark ? '#FFFFFF' : '#183326'} style={{ marginRight: 4 }} />}
                    <Text
                      style={[
                        styles.assetChipText,
                        {
                          color: isSelected
                            ? isDark
                              ? '#FFFFFF'
                              : '#183326'
                            : isDark
                            ? '#D1F5E8'
                            : '#64746A',
                          fontFamily: isSelected
                            ? typography.fontFamily.bold
                            : typography.fontFamily.medium,
                        },
                      ]}
                    >
                      {asset.label}
                    </Text>
                  </TouchableOpacity>
                );
              })}
            </ScrollView>
          </View>
        </View>

        {/* Nama Produk */}
        <View style={styles.fieldGroup}>
          <Text style={[styles.label, { color: isDark ? '#FFFFFF' : '#183326' }]}>
            Nama Produk Pertanian *
          </Text>
          <TextInput
            style={[styles.input, dynamicInputStyle]}
            value={name}
            onChangeText={setName}
            placeholder="Contoh: Bionava, Pupuk NPK, Sprayer..."
            placeholderTextColor={colors.inputPlaceholder}
          />
        </View>

        {/* Kategori Chips */}
        <View style={styles.fieldGroup}>
          <Text style={[styles.label, { color: isDark ? '#FFFFFF' : '#183326' }]}>
            Kategori Produk
          </Text>
          <View style={styles.categoryRow}>
            {CATEGORIES.map((cat) => {
              const isSelected = category === cat;
              return (
                <TouchableOpacity
                  key={cat}
                  onPress={() => setCategory(cat)}
                  style={[
                    styles.categoryChip,
                    {
                      backgroundColor: isSelected
                        ? isDark
                          ? 'rgba(64, 145, 108, 0.35)'
                          : '#D1F5E8'
                        : isDark
                        ? 'rgba(22, 58, 38, 0.60)'
                        : '#FFFFFF',
                      borderColor: isSelected
                        ? isDark
                          ? 'rgba(209, 245, 232, 0.45)'
                          : '#40916C'
                        : isDark
                        ? 'rgba(209, 245, 232, 0.18)'
                        : '#DDE8E0',
                    },
                  ]}
                  activeOpacity={0.8}
                >
                  <Text
                    style={[
                      styles.categoryText,
                      {
                        color: isSelected
                          ? isDark
                            ? '#FFFFFF'
                            : '#183326'
                          : isDark
                          ? '#D1F5E8'
                          : '#64746A',
                        fontFamily: isSelected
                          ? typography.fontFamily.bold
                          : typography.fontFamily.medium,
                      },
                    ]}
                  >
                    {cat}
                  </Text>
                </TouchableOpacity>
              );
            })}
          </View>
        </View>

        {/* Satuan Kemasan */}
        <View style={styles.fieldGroup}>
          <Text style={[styles.label, { color: isDark ? '#FFFFFF' : '#183326' }]}>
            Satuan Penjualan (Kemasan)
          </Text>
          <TextInput
            style={[styles.input, dynamicInputStyle]}
            value={unit}
            onChangeText={setUnit}
            placeholder="Sak (50kg), Botol (1L), Pcs, Unit..."
            placeholderTextColor={colors.inputPlaceholder}
          />
        </View>

        {/* Harga & Stok Row */}
        <View style={styles.row}>
          <View style={[styles.fieldGroup, styles.halfCol]}>
            <Text style={[styles.label, { color: isDark ? '#FFFFFF' : '#183326' }]}>
              Harga Jual (Rp) *
            </Text>
            <TextInput
              style={[styles.input, dynamicInputStyle]}
              value={price}
              onChangeText={setPrice}
              placeholder="85000"
              keyboardType="numeric"
              placeholderTextColor={colors.inputPlaceholder}
            />
          </View>
          <View style={[styles.fieldGroup, styles.halfCol]}>
            <Text style={[styles.label, { color: isDark ? '#FFFFFF' : '#183326' }]}>
              Stok Tersedia *
            </Text>
            <TextInput
              style={[styles.input, dynamicInputStyle]}
              value={stock}
              onChangeText={setStock}
              placeholder="50"
              keyboardType="numeric"
              placeholderTextColor={colors.inputPlaceholder}
            />
          </View>
        </View>

        {/* Batas Peringatan Menipis */}
        <View style={styles.fieldGroup}>
          <Text style={[styles.label, { color: isDark ? '#FFFFFF' : '#183326' }]}>
            Batas Peringatan Menipis (Alert)
          </Text>
          <TextInput
            style={[styles.input, dynamicInputStyle]}
            value={minStockAlert}
            onChangeText={setMinStockAlert}
            placeholder="15"
            keyboardType="numeric"
            placeholderTextColor={colors.inputPlaceholder}
          />
        </View>

        {/* Deskripsi */}
        <View style={styles.fieldGroup}>
          <Text style={[styles.label, { color: isDark ? '#FFFFFF' : '#183326' }]}>
            Deskripsi & Komposisi
          </Text>
          <TextInput
            style={[styles.input, styles.textArea, dynamicInputStyle]}
            value={description}
            onChangeText={setDescription}
            placeholder="Jelaskan spesifikasi, dosis penggunaan, dan anjuran aplikasi..."
            multiline
            numberOfLines={3}
            placeholderTextColor={colors.inputPlaceholder}
          />
        </View>

        {/* Actions */}
        <View
          style={[
            styles.actions,
            { borderTopColor: isDark ? 'rgba(255, 255, 255, 0.10)' : '#EFF4F0' },
          ]}
        >
          <Button variant="ghost" size="md" onPress={onClose} disabled={isLoading}>
            Batal
          </Button>
          <Button variant="primary" size="md" onPress={handleSubmit} isLoading={isLoading}>
            Simpan Produk
          </Button>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  formContainer: {
    gap: 14,
  },
  fieldGroup: {
    gap: 6,
  },
  label: {
    fontSize: 12.5,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  subLabel: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
    marginTop: 4,
    marginBottom: 4,
  },
  input: {
    borderWidth: 1.5,
    borderRadius: 16,
    paddingHorizontal: 14,
    paddingVertical: 10,
    fontSize: 13.5,
    fontFamily: typography.fontFamily.regular,
  },
  textArea: {
    minHeight: 76,
    textAlignVertical: 'top',
  },
  row: {
    flexDirection: 'row',
    gap: 10,
  },
  halfCol: {
    flex: 1,
  },
  imagePickerCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 14,
    padding: 14,
    borderWidth: 1.5,
    borderStyle: 'dashed',
    borderRadius: 18,
  },
  previewBox: {
    width: 72,
    height: 72,
    borderRadius: 14,
    borderWidth: 1.5,
    overflow: 'hidden',
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 4,
    elevation: 2,
  },
  previewImage: {
    width: '100%',
    height: '100%',
  },
  imageControls: {
    flex: 1,
    gap: 8,
  },
  imagePickerHint: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
  },
  deviceButtonRow: {
    flexDirection: 'row',
    gap: 8,
  },
  devicePickerBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    borderWidth: 1,
    borderRadius: 12,
    paddingHorizontal: 10,
    paddingVertical: 6,
  },
  devicePickerText: {
    fontSize: 11,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  removeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    alignSelf: 'flex-start',
  },
  removeImageText: {
    fontSize: 11,
    fontFamily: typography.fontFamily.semibold,
    color: '#EF4444',
    fontWeight: '600',
  },
  assetChipsSection: {
    gap: 4,
  },
  assetChipsRow: {
    gap: 6,
    paddingVertical: 4,
  },
  assetChip: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 12,
    borderWidth: 1,
  },
  assetChipText: {
    fontSize: 11,
  },
  categoryRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  categoryChip: {
    paddingHorizontal: 12,
    paddingVertical: 7,
    borderRadius: 12,
    borderWidth: 1,
  },
  categoryText: {
    fontSize: 12,
  },
  actions: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    gap: 10,
    paddingTop: 12,
    borderTopWidth: 1,
  },
});
