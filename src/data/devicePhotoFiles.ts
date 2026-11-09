import { Directory, File, Paths } from 'expo-file-system';
import { ImageManipulator, SaveFormat } from 'expo-image-manipulator';
import { fitLongEdge, PHOTOS_FOLDER, type PhotoFiles } from './photoFiles';

const MAX_LONG_EDGE = 1600;
const JPEG_QUALITY = 0.8;

function uniqueName(): string {
  const random = Math.random().toString(36).slice(2, 10);
  return `${Date.now().toString(36)}-${random}.jpg`;
}

export const devicePhotoFiles: PhotoFiles = {
  async store(sourceUri) {
    const folder = new Directory(Paths.document, PHOTOS_FOLDER);
    if (!folder.exists) folder.create({ intermediates: true, idempotent: true });

    const original = await ImageManipulator.manipulate(sourceUri).renderAsync();
    const size = fitLongEdge(original.width, original.height, MAX_LONG_EDGE);
    const image = size
      ? await ImageManipulator.manipulate(original).resize(size).renderAsync()
      : original;
    const saved = await image.saveAsync({ format: SaveFormat.JPEG, compress: JPEG_QUALITY });

    const name = uniqueName();
    new File(saved.uri).moveSync(new File(folder, name));
    return `${PHOTOS_FOLDER}/${name}`;
  },

  list() {
    const folder = new Directory(Paths.document, PHOTOS_FOLDER);
    if (!folder.exists) return [];
    return folder
      .list()
      .filter((entry): entry is File => entry instanceof File)
      .map((file) => `${PHOTOS_FOLDER}/${file.name}`);
  },

  remove(path) {
    const file = new File(Paths.document, path);
    if (file.exists) file.delete();
  },
};
