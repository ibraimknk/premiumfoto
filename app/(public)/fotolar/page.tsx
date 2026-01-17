'use client'

import { useState, useEffect } from 'react'
import Image from 'next/image'

interface ImageItem {
  name: string
  url: string
  fullUrl: string
}

export default function FotolarPage() {
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [images, setImages] = useState<ImageItem[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedImage, setSelectedImage] = useState<ImageItem | null>(null)
  const [selectedIndex, setSelectedIndex] = useState<number>(-1)
  const [deleting, setDeleting] = useState<string | null>(null)

  // Sayfa yüklendiğinde şifre kontrolü
  useEffect(() => {
    const savedAuth = localStorage.getItem('fotolar_auth')
    if (savedAuth === 'oxelio2024') {
      setIsAuthenticated(true)
    }
    loadImages()
  }, [])

  // Fotoğrafları yükle
  const loadImages = async () => {
    try {
      const response = await fetch('/api/uploads/list')
      const data = await response.json()
      if (data.success) {
        setImages(data.images || [])
      }
    } catch (error) {
      console.error('Fotoğraflar yüklenemedi:', error)
    } finally {
      setLoading(false)
    }
  }

  // Şifre kontrolü
  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault()
    if (password === 'oxelio2024') {
      setIsAuthenticated(true)
      localStorage.setItem('fotolar_auth', 'oxelio2024')
      setError('')
    } else {
      setError('Yanlış şifre!')
      setPassword('')
    }
  }

  // Çıkış
  const handleLogout = () => {
    setIsAuthenticated(false)
    localStorage.removeItem('fotolar_auth')
    setPassword('')
  }

  // Fotoğraf silme
  const handleDelete = async (fileName: string, e: React.MouseEvent) => {
    e.stopPropagation() // Grid item'a tıklamayı engelle
    
    if (!confirm('Bu fotoğrafı silmek istediğinize emin misiniz?')) {
      return
    }

    setDeleting(fileName)
    try {
      const response = await fetch(`/api/uploads/delete?file=${encodeURIComponent(fileName)}&password=oxelio2024`, {
        method: 'DELETE'
      })
      
      const data = await response.json()
      
      if (data.success) {
        // Listeden kaldır
        setImages(images.filter(img => img.name !== fileName))
        // Eğer silinen fotoğraf açıksa modal'ı kapat
        if (selectedImage?.name === fileName) {
          setSelectedImage(null)
          setSelectedIndex(-1)
        }
      } else {
        alert('Hata: ' + data.error)
      }
    } catch (error) {
      console.error('Silme hatası:', error)
      alert('Fotoğraf silinirken bir hata oluştu')
    } finally {
      setDeleting(null)
    }
  }

  // Fotoğraf açma (index ile)
  const handleImageClick = (image: ImageItem, index: number) => {
    setSelectedImage(image)
    setSelectedIndex(index)
  }

  // Önceki fotoğraf
  const handlePrevious = (e: React.MouseEvent) => {
    e.stopPropagation()
    if (selectedIndex > 0) {
      const prevIndex = selectedIndex - 1
      setSelectedIndex(prevIndex)
      setSelectedImage(images[prevIndex])
    }
  }

  // Sonraki fotoğraf
  const handleNext = (e: React.MouseEvent) => {
    e.stopPropagation()
    if (selectedIndex < images.length - 1) {
      const nextIndex = selectedIndex + 1
      setSelectedIndex(nextIndex)
      setSelectedImage(images[nextIndex])
    }
  }

  // Robots meta tag ekle
  useEffect(() => {
    const metaRobots = document.querySelector('meta[name="robots"]')
    if (metaRobots) {
      metaRobots.setAttribute('content', 'noindex, nofollow')
    } else {
      const meta = document.createElement('meta')
      meta.name = 'robots'
      meta.content = 'noindex, nofollow'
      document.head.appendChild(meta)
    }
  }, [])

  // Şifre ekranı
  if (!isAuthenticated) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-900 to-gray-800">
        <div className="bg-white rounded-lg shadow-2xl p-8 w-full max-w-md">
          <h1 className="text-3xl font-bold text-center mb-6 text-gray-800">
            🔒 Şifreli Galeri
          </h1>
          <form onSubmit={handleLogin} className="space-y-4">
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
                Şifre
              </label>
              <input
                type="password"
                id="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none"
                placeholder="Şifrenizi girin"
                autoFocus
              />
            </div>
            {error && (
              <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                {error}
              </div>
            )}
            <button
              type="submit"
              className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-4 rounded-lg transition duration-200"
            >
              Giriş Yap
            </button>
          </form>
        </div>
      </div>
    )
  }

  // Galeri ekranı
  return (
    <div className="min-h-screen bg-gray-100">
      {/* Header */}
      <header className="bg-white shadow-sm sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-gray-800">📸 Fotoğraf Galerisi</h1>
          <button
            onClick={handleLogout}
            className="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg transition duration-200"
          >
            Çıkış
          </button>
        </div>
      </header>

      {/* Galeri Grid */}
      <main className="max-w-7xl mx-auto px-4 py-8">
          {loading ? (
            <div className="text-center py-12">
              <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
              <p className="mt-4 text-gray-600">Fotoğraflar yükleniyor...</p>
            </div>
          ) : images.length === 0 ? (
            <div className="text-center py-12">
              <p className="text-gray-600 text-lg">Henüz fotoğraf yüklenmemiş.</p>
            </div>
          ) : (
            <>
              <p className="text-gray-600 mb-6">
                Toplam {images.length} fotoğraf
              </p>
              <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
                {images.map((image, index) => (
                  <div
                    key={image.name}
                    onClick={() => handleImageClick(image, index)}
                    className="relative aspect-square cursor-pointer group overflow-hidden rounded-lg shadow-md hover:shadow-xl transition-all duration-300 transform hover:scale-105"
                  >
                    <Image
                      src={image.url}
                      alt={image.name ? `${image.name} - Ataşehir fotoğrafçı Foto Uğur | Uğur Fotoğrafçılık` : 'Ataşehir fotoğrafçı Foto Uğur çalışması | Uğur Fotoğrafçılık'}
                      fill
                      className="object-cover"
                      sizes="(max-width: 640px) 50vw, (max-width: 1024px) 33vw, 20vw"
                      unoptimized
                    />
                    <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-30 transition-all duration-300 flex items-center justify-center">
                      <span className="text-white opacity-0 group-hover:opacity-100 text-4xl transition-opacity">
                        🔍
                      </span>
                    </div>
                    {/* Silme Butonu */}
                    <button
                      onClick={(e) => handleDelete(image.name, e)}
                      disabled={deleting === image.name}
                      className="absolute top-2 right-2 bg-red-600 hover:bg-red-700 text-white rounded-full w-8 h-8 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity z-10 disabled:opacity-50"
                      title="Fotoğrafı Sil"
                    >
                      {deleting === image.name ? (
                        <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                      ) : (
                        '×'
                      )}
                    </button>
                  </div>
                ))}
              </div>
            </>
          )}
      </main>

      {/* Modal - Büyük Fotoğraf */}
      {selectedImage && selectedIndex >= 0 && (
        <div
          className="fixed inset-0 bg-black bg-opacity-90 z-50 flex items-center justify-center p-4"
          onClick={() => {
            setSelectedImage(null)
            setSelectedIndex(-1)
          }}
        >
          <div className="relative max-w-7xl max-h-full w-full">
            {/* Kapat Butonu */}
            <button
              onClick={(e) => {
                e.stopPropagation()
                setSelectedImage(null)
                setSelectedIndex(-1)
              }}
              className="absolute top-4 right-4 text-white hover:text-gray-300 text-4xl font-bold z-10 bg-black bg-opacity-50 rounded-full w-12 h-12 flex items-center justify-center"
            >
              ×
            </button>

            {/* Silme Butonu */}
            <button
              onClick={(e) => {
                e.stopPropagation()
                handleDelete(selectedImage.name, e)
              }}
              disabled={deleting === selectedImage.name}
              className="absolute top-4 right-20 text-white hover:text-red-400 bg-red-600 hover:bg-red-700 rounded-full w-12 h-12 flex items-center justify-center z-10 disabled:opacity-50"
              title="Fotoğrafı Sil"
            >
              {deleting === selectedImage.name ? (
                <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
              ) : (
                '🗑️'
              )}
            </button>

            {/* Önceki Butonu */}
            {selectedIndex > 0 && (
              <button
                onClick={(e) => handlePrevious(e)}
                className="absolute left-4 top-1/2 -translate-y-1/2 text-white hover:text-gray-300 text-4xl font-bold z-10 bg-black bg-opacity-50 rounded-full w-12 h-12 flex items-center justify-center hover:bg-opacity-70 transition-all"
                title="Önceki Fotoğraf"
              >
                ‹
              </button>
            )}

            {/* Sonraki Butonu */}
            {selectedIndex < images.length - 1 && (
              <button
                onClick={(e) => handleNext(e)}
                className="absolute right-4 top-1/2 -translate-y-1/2 text-white hover:text-gray-300 text-4xl font-bold z-10 bg-black bg-opacity-50 rounded-full w-12 h-12 flex items-center justify-center hover:bg-opacity-70 transition-all"
                title="Sonraki Fotoğraf"
              >
                ›
              </button>
            )}

            {/* Fotoğraf */}
            <div className="relative w-full h-full" onClick={(e) => e.stopPropagation()}>
              <img
                src={selectedImage.fullUrl}
                alt={selectedImage.name ? `${selectedImage.name} - Ataşehir fotoğrafçı Foto Uğur | Uğur Fotoğrafçılık` : 'Ataşehir fotoğrafçı Foto Uğur çalışması | Uğur Fotoğrafçılık'}
                className="max-w-full max-h-[90vh] object-contain mx-auto"
              />
            </div>

            {/* Fotoğraf Bilgisi */}
            <div className="text-white text-center mt-4" onClick={(e) => e.stopPropagation()}>
              <p className="text-sm">
                {selectedIndex + 1} / {images.length}
              </p>
              <p className="text-xs text-gray-400 mt-1">
                {selectedImage.name}
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

